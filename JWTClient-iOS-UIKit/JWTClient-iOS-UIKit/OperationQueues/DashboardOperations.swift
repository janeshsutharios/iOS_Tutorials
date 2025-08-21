import Foundation

// Accumulator to collect results thread-safely across multiple operations
final class DashboardAccumulator {
    private let queue = DispatchQueue(label: "DashboardAccumulator.queue", attributes: .concurrent)
    private var _data = DashboardData()

    var data: DashboardData {
        queue.sync { _data }
    }

    func setProfile(_ result: Result<Profile, Error>) {
        queue.async(flags: .barrier) {
            switch result {
            case .success(let value):
                self._data.profile = value
            case .failure(let error):
                self._data.errors["profile"] = error
            }
        }
    }

    func setRestaurants(_ result: Result<[Restaurant], Error>) {
        queue.async(flags: .barrier) {
            switch result {
            case .success(let value):
                self._data.restaurants = value
            case .failure(let error):
                self._data.errors["restaurants"] = error
            }
        }
    }

    func setFestivals(_ result: Result<[Festival], Error>) {
        queue.async(flags: .barrier) {
            switch result {
            case .success(let value):
                self._data.festivals = value
            case .failure(let error):
                self._data.errors["festivals"] = error
            }
        }
    }

    func setUsers(_ result: Result<[User], Error>) {
        queue.async(flags: .barrier) {
            switch result {
            case .success(let value):
                self._data.users = value
            case .failure(let error):
                self._data.errors["users"] = error
            }
        }
    }
}

// MARK: - Endpoint Operations

final class ProfileOperation: AsynchronousOperation {
    private let api: APIService
    private let auth: AuthProviding
    private let accumulator: DashboardAccumulator

    init(api: APIService, auth: AuthProviding, accumulator: DashboardAccumulator) {
        self.api = api
        self.auth = auth
        self.accumulator = accumulator
        super.init()
    }

    override func main() {
        if isCancelled { finish(); return }
        api.fetchWithRetry(auth: auth, { token, callback in
            self.api.fetchProfile(with: token, completion: callback)
        }) { result in
            self.accumulator.setProfile(result)
            self.finish()
        }
    }
}

final class RestaurantsOperation: AsynchronousOperation {
    private let api: APIService
    private let auth: AuthProviding
    private let accumulator: DashboardAccumulator

    init(api: APIService, auth: AuthProviding, accumulator: DashboardAccumulator) {
        self.api = api
        self.auth = auth
        self.accumulator = accumulator
        super.init()
    }

    override func main() {
        if isCancelled { finish(); return }
        api.fetchWithRetry(auth: auth, { token, callback in
            self.api.fetchRestaurants(with: token, completion: callback)
        }) { result in
            self.accumulator.setRestaurants(result)
            self.finish()
        }
    }
}

final class FestivalsOperation: AsynchronousOperation {
    private let api: APIService
    private let auth: AuthProviding
    private let accumulator: DashboardAccumulator

    init(api: APIService, auth: AuthProviding, accumulator: DashboardAccumulator) {
        self.api = api
        self.auth = auth
        self.accumulator = accumulator
        super.init()
    }

    override func main() {
        if isCancelled { finish(); return }
        api.fetchWithRetry(auth: auth, { token, callback in
            self.api.fetchFestivals(with: token, completion: callback)
        }) { result in
            self.accumulator.setFestivals(result)
            self.finish()
        }
    }
}

final class UsersOperation: AsynchronousOperation {
    private let api: APIService
    private let auth: AuthProviding
    private let accumulator: DashboardAccumulator

    init(api: APIService, auth: AuthProviding, accumulator: DashboardAccumulator) {
        self.api = api
        self.auth = auth
        self.accumulator = accumulator
        super.init()
    }

    override func main() {
        if isCancelled { finish(); return }
        api.fetchWithRetry(auth: auth, { token, callback in
            self.api.fetchUsers(with: token, completion: callback)
        }) { result in
            self.accumulator.setUsers(result)
            self.finish()
        }
    }
}

// MARK: - Managers

final class DashboardConcurrentQueueManager {
    private let queue: OperationQueue

    init(maxConcurrent: Int = 4) {
        let q = OperationQueue()
        q.name = "DashboardConcurrentQueue"
        q.maxConcurrentOperationCount = maxConcurrent
        self.queue = q
    }

    func fetchDashboard(api: APIService, auth: AuthProviding, completion: @escaping (DashboardData) -> Void) {
        let accumulator = DashboardAccumulator()

        let profileOp = ProfileOperation(api: api, auth: auth, accumulator: accumulator)
        let restaurantsOp = RestaurantsOperation(api: api, auth: auth, accumulator: accumulator)
        let festivalsOp = FestivalsOperation(api: api, auth: auth, accumulator: accumulator)
        let usersOp = UsersOperation(api: api, auth: auth, accumulator: accumulator)

        let finishOp = BlockOperation { }
        [profileOp, restaurantsOp, festivalsOp, usersOp].forEach { finishOp.addDependency($0) }
        finishOp.completionBlock = { [weak finishOp] in
            _ = finishOp // keep strong until completionBlock runs
            DispatchQueue.main.async {
                completion(accumulator.data)
            }
        }

        queue.addOperations([profileOp, restaurantsOp, festivalsOp, usersOp, finishOp], waitUntilFinished: false)
    }
}

final class DashboardSequentialQueueManager {
    private let queue: OperationQueue

    init() {
        let q = OperationQueue()
        q.name = "DashboardSequentialQueue"
        q.maxConcurrentOperationCount = 1
        self.queue = q
    }

    func fetchDashboard(api: APIService, auth: AuthProviding, completion: @escaping (DashboardData) -> Void) {
        let accumulator = DashboardAccumulator()

        let profileOp = ProfileOperation(api: api, auth: auth, accumulator: accumulator)
        let restaurantsOp = RestaurantsOperation(api: api, auth: auth, accumulator: accumulator)
        let festivalsOp = FestivalsOperation(api: api, auth: auth, accumulator: accumulator)
        let usersOp = UsersOperation(api: api, auth: auth, accumulator: accumulator)

        restaurantsOp.addDependency(profileOp)
        festivalsOp.addDependency(restaurantsOp)
        usersOp.addDependency(festivalsOp)

        let finishOp = BlockOperation { }
        finishOp.addDependency(usersOp)
        finishOp.completionBlock = { [weak finishOp] in
            _ = finishOp
            DispatchQueue.main.async {
                completion(accumulator.data)
            }
        }

        queue.addOperations([profileOp, restaurantsOp, festivalsOp, usersOp, finishOp], waitUntilFinished: false)
    }
}


