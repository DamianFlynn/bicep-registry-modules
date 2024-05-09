using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

// Azure
using Azure.Identity;
using Azure.ResourceManager;
using Azure.ResourceManager.ResourceGraph;
using Azure.ResourceManager.ResourceGraph.Models;
using Microsoft.Identity.Client;
using Azure.ResourceManager.Resources.Models;
using System.Security.Cryptography.X509Certificates;
using System.Text.Json.Serialization;

namespace CustomProvider.Action
{
    class RGRecord
    {
        [JsonPropertyName("id")]
        public string? Id { get; set; } = null;
    }

    public class actionSample
    {
        private readonly ILogger<actionSample> _logger;

        public actionSample(ILogger<actionSample> logger)
        {
            _logger = logger;
        }

        [Function("actionSample")]
        public async Task<IActionResult> Run([HttpTrigger(AuthorizationLevel.Anonymous, "get", "post", Route = "subscriptions/{subscriptionId}/resourcegroups/{resourceGroupName}/providers/Microsoft.CustomProviders/resourceproviders/{minirpname}/{action}")] HttpRequest req,
        string subscriptionId,
        string resourceGroupName,
        string minirpname,
        string action)
        {
            _logger.LogInformation("Action Triggered.");

            _logger.LogInformation($"The Custom Provider Function 'actionSample' received a request '{req.Method}'.");
            _logger.LogInformation($"The miniRpName was: '{minirpname}'");
            _logger.LogInformation($"The action was: '{action}'");
            _logger.LogInformation($"The HTTP Method was: '{req.Method}'");
            
            var requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            _logger.LogInformation($"The BODY was: '{requestBody}'");

            switch (action) 
            {
                case "ping":
                    _logger.LogInformation($"Starting 'ping' action process for method: '{req.Method}'");
                    if (req.Method != HttpMethod.Post.Method)
                    {
                        return new StatusCodeResult(StatusCodes.Status405MethodNotAllowed);
                    }
                    else
                    {
                        var host = req.Headers["Host"].FirstOrDefault() ?? "anonymous";
                        _logger.LogInformation($"The host was: '{host}'");
                        var content = $"{{ 'pingcontent' : {{ 'source' : '{host}' }} , 'message' : 'hello {host}'}}";
                        return new OkObjectResult(content);
                    }

                case "listMyCustomAction":
                    _logger.LogInformation($"Starting 'listMyCustomAction' action process for method: '{req.Method}'");
                    if (req.Method != HttpMethod.Post.Method)
                    {
                        return new StatusCodeResult(StatusCodes.Status405MethodNotAllowed);
                    }
                    else
                    {
                        var host = req.Headers["Host"].FirstOrDefault() ?? "anonymous";
                        _logger.LogInformation($"The host was: '{host}'");
                        var resultObject = new 
                        {
                            listMyActionResult = new 
                            {
                                source = host,
                                timestamp = DateTime.UtcNow,
                                randomString = Guid.NewGuid().ToString(),
                                body = requestBody
                            },
                            message = $"see this? {host}"
                        };
                        return new OkObjectResult(resultObject);
                    }
            

                case "listSubscriptions":

                    _logger.LogInformation($"Starting 'listSubscriptions' action process for method: '{req.Method}'");

                    _logger.LogInformation($"Calling armClient to GetSubscriptions");
                    // Set up the Azure ARM client with DefaultAzureCredential
                    // This will use the managed identity when running on Azure services that support it
                    ArmClient client = new ArmClient(new DefaultAzureCredential());
                    
                    try
                    {   
                        _logger.LogInformation($"Get Tenant Resource");
                        var tenantResource = client.GetTenants().Where(x=> x.Data.TenantId == new Guid("c0ff482c-f0bb-426d-b91b-5fae5b5ace06")).FirstOrDefault();
                        
                        _logger.LogInformation($"Tenant Information: {tenantResource.Data.TenantId}");
                        
                        _logger.LogInformation($"Get Tenant Resources");
                        // var azureResourceGraphQuery = "resources| where type == \"microsoft.network/virtualnetworks\" | project id";
                        var azureResourceGraphQuery = "resources | project id";
                        ResourceQueryContent content = new ResourceQueryContent(azureResourceGraphQuery){};
                        ResourceQueryResult result = await tenantResource.GetResourcesAsync(content);
                        _logger.LogInformation($"Resource Graph Query Result: {result.Data}");



                        var resultRecords = result.Data.ToObjectFromJson<List<RGRecord>>();
                        var resultList = new List<string>();

                        foreach (var record in resultRecords)
                        {
                            _logger.LogInformation($"Resource Id: {record.Id}");
                            resultList.Add(record.Id);
                        }

                        _logger.LogInformation($"Preparing the Response Object");
                        var resultObject = new
                        {
                            subscriptions = new
                            {
                                timestamp = DateTime.UtcNow,
                                randomString = Guid.NewGuid().ToString(),
                                resources = resultList
                            },
                            message = $"Subscription list for Tenant '{tenantResource.Data.TenantId}'"
                        };

                        return new OkObjectResult(resultObject);
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError($"An error occurred while listing subscriptions: {ex.Message}");
                        return new BadRequestObjectResult(new { error = "Failed to list subscriptions." });
                }
                

                default:
                    return new StatusCodeResult(StatusCodes.Status204NoContent);
            }

        }
    }
}
