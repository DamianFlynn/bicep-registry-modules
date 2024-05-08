using Microsoft.Extensions.Logging;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;

namespace CustomProvider.Resource
{
    public class resourceSample
    {
        private readonly ILogger<resourceSample> _logger;

        public resourceSample(ILogger<resourceSample> logger)
        {
            _logger = logger;
        }
        private static string separator = ":::";

        //[HttpTrigger(AuthorizationLevel.Anonymous, "get", "post", "put", "delete", Route = "subscriptions/{subscriptionId}/resourcegroups/{resourceGroupName}/providers/{miniRpName}/{action}/{name}")] HttpRequestData req,
        [Function("resourceSample")]
        public async Task<IActionResult> Run(                                                                                               
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", "post", "put", "delete", Route = "subscriptions/{subscriptionId}/resourcegroups/{resourceGroupName}/providers/Microsoft.CustomProviders/resourceproviders/{minirpname}/{action}/{name}")] HttpRequestData req,
            string subscriptionId,
            string resourceGroupName,
            string miniRpName,
            string action,
            string name,
            FunctionContext executionContext)
        {

            _logger.LogInformation("Resource Triggered.");

            _logger.LogInformation($"The Custom Provider Function 'resourceSample' received a request '{req.Method}'.");
            _logger.LogInformation($"The miniRpName was: '{miniRpName}'");
            _logger.LogInformation($"The action was: '{action}'");
            _logger.LogInformation($"The HTTP Method was: '{req.Method}'");
            _logger.LogInformation($"The name was: '{name}'");
            
            var requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            _logger.LogInformation($"The BODY was: '{requestBody}'");


            var id = $"/subscriptions/{subscriptionId}/resourcegroups/{resourceGroupName}/providers/{miniRpName}/{action}/{name}".ToLower();
            _logger.LogInformation($"The id is: '{id}'");
            
            var resultObject = new 
            {
                id = id,
                name = name,
                type = "Microsoft.CustomProviders/resourceproviders/users",
                properties = new 
                {
                    // source = host,
                    timestamp = DateTime.UtcNow,
                    randomString = Guid.NewGuid().ToString(),
                    body = requestBody
                },
            };


            // string instorageBlob = req.Headers.GetValues("instorageBlob").FirstOrDefault();
            // string outstorageBlob = instorageBlob; // Placeholder for actual storage blob handling logic

            if (action.ToLower() == "users")
            {
                _logger.LogInformation($"Working on action type: '{action}'");
                // var userInfo = GetUserDictionaryFromFile(instorageBlob, _logger);

                switch (req.Method)
                {
                    case "PUT":
                        _logger.LogInformation($"Processing '{action}' action for method: '{req.Method}'");

                        // var requestBody = await req.ReadAsStringAsync();
                        // var userResource = JsonSerializer.Deserialize<UserResource>(requestBody);
                        // userResource.id = id;
                        // userResource.name = name;
                        // userResource.type = "Microsoft.CustomProviders/resourceproviders/users";

                        // userInfo[id] = userResource; // Add or update the user

                        // var host = req.Headers["Host"].FirstOrDefault() ?? "anonymous";
                        // _logger.LogInformation($"The host was: '{host}'");

                        _logger.LogInformation($"Returning the object: '{resultObject.ToString()}'");
                        return new OkObjectResult(resultObject);


                        // return new OkObjectResult(userResource);

                    case "GET":
                        _logger.LogInformation($"Processing '{action}' action for method: '{req.Method}'");
                        // if (!string.IsNullOrEmpty(name))
                        // {
                        //     if (userInfo.TryGetValue(id, out UserResource user))
                        //     {
                        //         return new OkObjectResult(user);
                        //     }
                        //     return new StatusCodeResult(StatusCodes.Status404NotFound);
                        // }
                        // else
                        // {
                        //     return new OkObjectResult(userInfo.Values);
                        // }
                        return new OkObjectResult(resultObject);

                    case "DELETE":
                        _logger.LogInformation($"Processing '{action}' action for method: '{req.Method}'");
                        // if (userInfo.Remove(id))
                        // {
                        //     return new OkObjectResult(id);
                        // }
                        // return new StatusCodeResult(StatusCodes.Status404NotFound);
                        return new OkObjectResult(resultObject);

                    default:
                        _logger.LogInformation($"Processing '{action}' action for method: '{req.Method}' [Default]");
                        return new StatusCodeResult(StatusCodes.Status405MethodNotAllowed);
                }
            }

            return new StatusCodeResult(StatusCodes.Status400BadRequest);
        }

        private static Dictionary<string, UserResource> GetUserDictionaryFromFile(string storageBlob, ILogger logger)
        {
            var dictionary = new Dictionary<string, UserResource>();

            if (string.IsNullOrEmpty(storageBlob)) return dictionary;

            var users = storageBlob.Split(new[] { separator }, System.StringSplitOptions.RemoveEmptyEntries);
            foreach (var user in users)
            {
                var data = user.Split(',');
                if (data.Length == 5)
                {
                    dictionary.Add(data[2], new UserResource
                    {
                        name = data[0],
                        type = data[1],
                        id = data[2],
                        properties = new User { FullName = data[3], Location = data[4] }
                    });
                }
            }

            return dictionary;
        }
    }

    public class UserResource
    {
        public string name { get; set; }
        public string type { get; set; }
        public string id { get; set; }
        public User properties { get; set; }
    }

    public class User
    {
        public string FullName { get; set; }
        public string Location { get; set; }
    }
}