import XCTest
import QBRepository
import RealmSwift

class RealmRepositoryTests: XCTestCase {

    var repository: RealmRepository<QuickEmployee>?

    override func setUp() {
        super.setUp()
        let testRealm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "Test"))
        repository = RealmRepository<QuickEmployee>(realm: testRealm)
    }
    
    override func tearDown() {
        let testRealm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "Test"))
        repository = RealmRepository<QuickEmployee>(realm: testRealm)
        super.tearDown()
    }
    
    func testGetAll() {
        addRandomMockObjects(repo: repository)

        repository?.getAll({ (allObjects) in
            XCTAssert(allObjects.count == 4)
        })
    }


    func testDeleteAll() {
        addRandomMockObjects(repo: repository)

        var deletionError: Error?
        repository?.deleteAll({ error in
            deletionError = error
        })

        repository?.getAll({ allObjects in
            XCTAssert(allObjects.isEmpty && deletionError == nil)
        })
    }

    func testFilter(){

        repository?.create(QuickEmployee(name: "Torsten", age: 19, data: Data()), { _ in })
        repository?.create(QuickEmployee(name: "Torben", age: 21, data: Data()), { _ in })
        repository?.create(QuickEmployee(name: "Tim", age: 87, data: Data()), { _ in })
        repository?.create(QuickEmployee(name: "Struppi", age: 3, data: Data()), { _ in })

        let newEmployeeName = "Zementha"
        repository?.create(QuickEmployee(name: newEmployeeName, age: 34, data: Data()), { _ in })

        repository?.getElements(filteredBy: "name = %@", newEmployeeName, completion: { (filteredEmployees) in
            guard let firstEmployee = filteredEmployees.first else { return }

            let correctEmployee = firstEmployee.name == newEmployeeName
            let containsOneEmployee = filteredEmployees.count == 1

            XCTAssert(correctEmployee && containsOneEmployee)
        })
    }


    func testSorting(){

        let tim = QuickEmployee(name: "Tim", age: 87, data: Data())
        repository?.create(tim, { _ in })

        let struppi = QuickEmployee(name: "Struppi", age: 3, data: Data())
        repository?.create(struppi, { _ in })

        let torsten = QuickEmployee(name: "Torsten", age: 19, data: Data())
        repository?.create(torsten, { _ in })

        let torben = QuickEmployee(name: "Torben", age: 21, data: Data())
        repository?.create(torben, { _ in })

        repository?.getElements(sorted: \QuickEmployee.age, ascending: false, completion: { (filteredEmployees) in
            let filteredArray = Array(filteredEmployees)

            guard let firstEmployee = filteredArray.first else { return }
            guard let lastEmployee = filteredArray.last else { return }

            XCTAssert(firstEmployee.age == struppi.age && lastEmployee.age == tim.age)
        })

    }

    // MARK: Helper Methods

    func addRandomMockObjects(repo: RealmRepository<QuickEmployee>?){
        repo?.create(QuickEmployee(name: "Quirin", age: -1, data: Data()), { _ in })
        repo?.create(QuickEmployee(name: "Stefan", age: -1, data: Data()), { _ in })
        repo?.create(QuickEmployee(name: "Sebi", age: 22, data: Data()), { _ in })
        repo?.create(QuickEmployee(name: "Malte" ,age: -1, data: Data()), { _ in })
        repo?.create(QuickEmployee(name: "Joan", age:23, data: Data()), { _ in })
    }

}


class QuickEmployee: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var age: Int = 0
    @objc dynamic var data: Data = Data()

    convenience init(name: String, age: Int, data: Data) {
        self.init()

        self.name = name
        self.age = age
        self.data = data
    }
}
