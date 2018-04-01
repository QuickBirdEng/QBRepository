import XCTest
import QBRepository
import CoreData

@available(iOS 10.0, *)
class CoreDataRepositoryTests: XCTestCase {

    fileprivate var repository: CoreDataRepository<CDEmployee>!

    fileprivate let testEmployees: [Employee] = [
        Employee(name: "Quirin", age: 21, data: Data()),
        Employee(name: "Stefan", age: 24, data: Data()),
        Employee(name: "Sebi", age: 22, data: Data()),
        Employee(name: "Malte" ,age: 24, data: Data()),
        Employee(name: "Joan", age: 23, data: Data()),
        ]

    fileprivate lazy var managedObjectModel: NSManagedObjectModel = {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle(for: type(of: self))] )!
        return managedObjectModel
    }()

    fileprivate lazy var mockPersistantContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CDModel", managedObjectModel: self.managedObjectModel)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false // Make it simpler in test env

        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { (description, error) in
            // Check if the data store is in memory
            precondition( description.type == NSInMemoryStoreType )

            // Check if creating container wrong
            if let error = error {
                fatalError("Create an in-mem coordinator failed \(error)")
            }
        }
        return container
    }()

    override func setUp() {
        super.setUp()

        repository = CoreDataRepository<CDEmployee>(context: mockPersistantContainer.viewContext)

        addRandomMockObjects(testEmployees, to: repository)
    }

    func testGetAll() {
        let allObjects = repository.getAll()
        XCTAssertEqual(allObjects.underestimatedCount, testEmployees.count)
    }


    func testDeleteAll() {
        let deletionError = repository.deleteAll()
        let allObjects = repository.getAll()

        XCTAssert(allObjects.isEmpty && deletionError == nil)
    }

    func testFilter() {
        let newEmployeeName = "Zementha"

        addRandomMockObjects([
            Employee(name: "Torsten", age: 19, data: Data()),
            Employee(name: "Torben", age: 21, data: Data()),
            Employee(name: "Tim", age: 87, data: Data()),
            Employee(name: "Struppi", age: 3, data: Data()),
            Employee(name: newEmployeeName, age: 34, data: Data())
            ], to: repository)

        let filteredEmployees = repository.getElements(filteredByPredicate: \.name == newEmployeeName)
        guard let firstEmployee = filteredEmployees.first else { return }

        XCTAssertEqual(firstEmployee.name, newEmployeeName)
        XCTAssertEqual(filteredEmployees.count, 1)
    }

    func testSortingAscending() {
        let stdlibSortedEmployees = testEmployees.sorted(by: { $0.age < $1.age })
        let filteredEmployees = repository.getElements(sortedBy: \.age)

        XCTAssert(Int(filteredEmployees.first?.age ?? 0) == stdlibSortedEmployees.first?.age)
        XCTAssert(Int(filteredEmployees.last?.age ?? 0) == stdlibSortedEmployees.last?.age)
    }

    func testSortingDescending() {
        let stdlibSortedEmployees = testEmployees.sorted(by: { $0.age > $1.age })
        let filteredEmployees = repository.getElements(sortedBy: \.age).reversed()

        XCTAssert(Int(filteredEmployees.first?.age ?? 0) == stdlibSortedEmployees.first?.age)
        XCTAssert(Int(filteredEmployees.last?.age ?? 0) == stdlibSortedEmployees.last?.age)
    }

    func testDistinct() {
        let stdlibFilteredAges = Set(testEmployees.map { $0.age })
        let distinctAgeEmployees = repository.getElements(distinctUsing: \.age)
        let ages = distinctAgeEmployees.map { $0.age }

        XCTAssert(stdlibFilteredAges.count == ages.count)
    }

    // MARK: Helper Methods

    private func addRandomMockObjects(_ employees: [Employee], to repository: CoreDataRepository<CDEmployee>) {
        repository.deleteAll()

        let cdEmployees = employees.map { employee -> CDEmployee in
            let cdEmployee = repository.makeEntity()
            cdEmployee.id = employee.id
            cdEmployee.name = employee.name
            cdEmployee.age = Int32(employee.age)
            cdEmployee.data = employee.data
            return cdEmployee
        }

        repository.create(cdEmployees)
    }

}
