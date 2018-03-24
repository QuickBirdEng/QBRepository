import XCTest
import QBRepository
import RealmSwift

class RealmRepositoryTests: XCTestCase {

    var repository: RealmRepository<QuickEmployee>!

    let testEmployees: [QuickEmployee] = [
        QuickEmployee(name: "Quirin", age: 21, data: Data()),
        QuickEmployee(name: "Stefan", age: 24, data: Data()),
        QuickEmployee(name: "Sebi", age: 22, data: Data()),
        QuickEmployee(name: "Malte" ,age: 24, data: Data()),
        QuickEmployee(name: "Joan", age: 23, data: Data()),
    ]

    override func setUp() {
        super.setUp()

        let testRealm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "Test"))
        repository = RealmRepository<QuickEmployee>(realm: testRealm)

        addRandomMockObjects(to: repository)
    }

    func testGetAll() {
        var isCalled = false

        repository.getAll { allObjects in
            isCalled = true
            XCTAssertEqual(allObjects.underestimatedCount, testEmployees.count)
        }

        XCTAssert(isCalled)
    }


    func testDeleteAll() {
        var isCalled = false

        repository.deleteAll() { deletionError in
            repository.getAll() { allObjects in
                isCalled = true
                XCTAssert(allObjects.isEmpty && deletionError == nil)
            }
        }

        XCTAssert(isCalled)
    }

    func testFilter() {
        var isCalled = false

        repository.create(QuickEmployee(name: "Torsten", age: 19, data: Data())) { _ in }
        repository.create(QuickEmployee(name: "Torben", age: 21, data: Data())) { _ in }
        repository.create(QuickEmployee(name: "Tim", age: 87, data: Data())) { _ in }
        repository.create(QuickEmployee(name: "Struppi", age: 3, data: Data())) { _ in }

        let newEmployeeName = "Zementha"
        repository.create(QuickEmployee(name: newEmployeeName, age: 34, data: Data())) { _ in }

        repository.getElements(filteredBy: "name = %@", newEmployeeName) { filteredEmployees in
            guard let firstEmployee = filteredEmployees.first else { return }
            isCalled = true

            XCTAssertEqual(firstEmployee.name, newEmployeeName)
            XCTAssertEqual(filteredEmployees.count, 1)
        }

        XCTAssert(isCalled)
    }


    func testSortingAscending() {
        var isCalled = false
        let stdlibSortedEmployees = testEmployees.sorted(by: { $0.age < $1.age })

        repository.getElements(sortedBy: \QuickEmployee.age) { filteredEmployees in
            isCalled = true
            let filteredArray = Array(filteredEmployees)

            XCTAssert(filteredArray.first?.age == stdlibSortedEmployees.first?.age)
            XCTAssert(filteredArray.last?.age == stdlibSortedEmployees.last?.age)
        }

        XCTAssert(isCalled)
    }

    func testSortingDescending() {
        var isCalled = false
        let stdlibSortedEmployees = testEmployees.sorted(by: { $0.age > $1.age })

        repository.getElements(sortedBy: \QuickEmployee.age, ascending: false) { filteredEmployees in
            isCalled = true
            let filteredArray = Array(filteredEmployees)

            XCTAssert(filteredArray.first?.age == stdlibSortedEmployees.first?.age)
            XCTAssert(filteredArray.last?.age == stdlibSortedEmployees.last?.age)
        }

        XCTAssert(isCalled)
    }

    // MARK: Helper Methods

    private func addRandomMockObjects(to repository: RealmRepository<QuickEmployee>) {
        repository.deleteAll { _ in }
        repository.create(testEmployees) { _ in }
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
