import XCTest
import QBRepository
import RealmSwift

class RealmrepositorysitoryTests: XCTestCase {

    var repository: RealmRepository<QuickEmployee>!

    override func setUp() {
        super.setUp()
        let testRealm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "Test"))
        repository = RealmRepository<QuickEmployee>(realm: testRealm)
    }
    
    override func tearDown() {
        repository.deleteAll { _ in }
        let testRealm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "Test"))
        repository = RealmRepository<QuickEmployee>(realm: testRealm)
        super.tearDown()
    }
    
    func testGetAll() {
        let testEmployees = createMockEmployees()
        repository.create(testEmployees) { _ in }
        repository.getAll{ (allObjects) in
            XCTAssert(allObjects.count == testEmployees.count)
        }
    }


    func testDeleteAll() {
        let testEmployees = createMockEmployees()
        repository.create(testEmployees) { _ in }

        var deletionError: Error?
        repository.deleteAll() { error in
            deletionError = error
        }

        repository.getAll() { allObjects in
            XCTAssert(allObjects.isEmpty && deletionError == nil)
        }
    }

    func testFilter(){
        repository.create(QuickEmployee(name: "Torsten", age: 19, data: Data())) { _ in }
        repository.create(QuickEmployee(name: "Torben", age: 21, data: Data())) { _ in }
        repository.create(QuickEmployee(name: "Tim", age: 87, data: Data())) { _ in }
        repository.create(QuickEmployee(name: "Struppi", age: 3, data: Data())) { _ in }

        let newEmployeeName = "Zementha"
        repository.create(QuickEmployee(name: newEmployeeName, age: 34, data: Data())) { _ in }

        repository.getElements(filteredBy: "name = %@", newEmployeeName) { filteredEmployees in
            guard let firstEmployee = filteredEmployees.first else { return }

            let correctEmployee = firstEmployee.name == newEmployeeName
            let containsOneEmployee = filteredEmployees.count == 1

            XCTAssert(correctEmployee && containsOneEmployee)
        }
    }


    func testSortingAscending(){
        let tim = QuickEmployee(name: "Tim", age: 87, data: Data())
        let struppi = QuickEmployee(name: "Struppi", age: 3, data: Data())
        let torsten = QuickEmployee(name: "Torsten", age: 19, data: Data())
        let torben = QuickEmployee(name: "Torben", age: 21, data: Data())
        let employeeArray = [tim,struppi,torsten,torben]

        repository.create(employeeArray) { _ in }

        repository.getElements(sortedBy: \QuickEmployee.age) { filteredEmployees in
            let sortedEmployees = employeeArray.sorted { e1, e2 -> Bool in
                return e1.age < e2.age
            }

            let repositoryEmployees = Array(filteredEmployees)
            guard let firstOrginalEmployee = sortedEmployees.first else { return }
            guard let lastOrginalEmployee = sortedEmployees.last else { return }

            guard let firstrepositoryEmployee = repositoryEmployees.first else { return }
            guard let lastrepositoryEmployee = repositoryEmployees.last else { return }

            XCTAssert(firstOrginalEmployee == firstrepositoryEmployee
                && lastOrginalEmployee == lastrepositoryEmployee)
        }
    }

    func testSortingDescending() {
        let tim = QuickEmployee(name: "Tim", age: 87, data: Data())
        let struppi = QuickEmployee(name: "Struppi", age: 3, data: Data())
        let torsten = QuickEmployee(name: "Torsten", age: 19, data: Data())
        let torben = QuickEmployee(name: "Torben", age: 21, data: Data())
        let employeeArray = [tim, struppi, torsten, torben]

        repository.create(employeeArray) { _ in }

        repository.getElements(sortedBy: \QuickEmployee.age, ascending: false) { filteredEmployees in
            let sortedEmployees = employeeArray.sorted { e1, e2 -> Bool in
                return e1.age > e2.age
            }

            let repositoryEmployees = Array(filteredEmployees)
            guard let firstOrginalEmployee = sortedEmployees.first else { return }
            guard let lastOrginalEmployee = sortedEmployees.last else { return }

            guard let firstrepositoryEmployee = repositoryEmployees.first else { return }
            guard let lastrepositoryEmployee = repositoryEmployees.last else { return }


            XCTAssert(firstOrginalEmployee == firstrepositoryEmployee
                && lastOrginalEmployee == lastrepositoryEmployee)
        }
    }

    // MARK: Helper Methods

    func createMockEmployees() -> [QuickEmployee] {
        return [QuickEmployee(name: "Quirin", age: -1, data: Data()),
                QuickEmployee(name: "Stefan", age: -1, data: Data()),
                QuickEmployee(name: "Sebi", age: 22, data: Data()),
                QuickEmployee(name: "Malte" ,age: -1, data: Data()),
                QuickEmployee(name: "Joan", age:23, data: Data())]
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

    static func == (lhs: QuickEmployee, rhs: QuickEmployee) -> Bool {
        return lhs.name == rhs.name && lhs.age == rhs.age && lhs.data == rhs.data
    }
}
