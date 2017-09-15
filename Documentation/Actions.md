# Coherence
## Actions

**Coherenc.Connect** contains an extensive *process management and monitoring system* based around its concept of the `Action`. Actions encapsulate work related to keeping the data cache in sync
with remote systems through web services as well as offering an environment for running generic tasks within the system.


**Benefits of Actions:**
- [x] Encapsulates work in a manageable class.
- [x] Executes in an managed container.
- [x] Provides managed services by the container.
- [x] Is cancelable.
- [x] Can be monitored during execution.
- [x] Captures run time statistics while executing.
- [x] Can be automatically executed by Coherence to keep the cache in sync (Future)

Actions are executed by Connect via the `execute()` function and return an `ActionProxy` which allows you to control and monitor the action as they are executing.

There are 2 primary types of Actions, a `GenericAction` and an `EntityAction` which are described in more detail below.

### Generic Action

A `GenericAction` is an Action that allows you to encapsulate, monitor, and control the life cycle of just about any type of work including web services that do not interact with the database.  The template below represents a simple template for building you own actions.
The `Action` should implement the `GenericAction` protocol and has a requirement for 2 methods, `execute()` and `cancel()`.  These methods are called back during execution by the container.


```swift

class MyGenericAction: GenericAction {

    internal var canceled: Bool = false

    ///
    /// This will be executed by the container
    ///
    func execute() throws {
    
        guard !canceled else { return }

        /// Perform work here
    }

    func cancel() {
        self.canceled = true
    }
}
```


### Entity Action

In addition, there are `EntityAction`'s which encapsulate data cache synchronization functionality and offer database specific services while offering the same life cycle management functionality as a `GenericAction`.

```swift

class MyEntityAction: EntityAction {

    internal var canceled: Bool = false

    private let webService: MyWebService
    private let parameter1: Double
    private let parameter2: Double

    ///
    /// Capture the parameters you require for the Web Service call in your init
    ///
    public init(webService: MyWebService, parameter1: Double, parameter1: Double) {
        self.webService = webService
        self.parameter1 = parameter1
        self.parameter1 = parameter1
    }

    ///
    /// This will be executed by the container passing you an `ActionContext` to use for your database work.
    ///
    func execute(context: ActionContext) throws {

        guard !canceled else { return }

        let (data, response, error) = webService.execute(request: MyWebServiceTask(parameter1: self.parameter1, parameter2: self.parameter2))

        guard !canceled else { return }

        if let response = response as? HTTPURLResponse {

            switch response.statusCode {

            case 200:
                ///
                /// Process the returned data
                ///
                break
            default:
                break
            }
        }

        ///
        ///  Errors can be thrown directly from actions.  The container will
        ///  catch them and report them back through the notification system
        ///  and you completion block if one was supplied.
        ///
        if let error = error {
            throw error
        }
    }
}
```