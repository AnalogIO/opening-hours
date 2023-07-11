using System.Net;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Azure.WebJobs.Extensions.OpenApi.Core.Attributes;
using Microsoft.Extensions.Logging;
using Microsoft.OpenApi.Models;

namespace OpeningHours
{
    public class IsOpen
    {
        private readonly ILogger<IsOpen> _logger;

        public IsOpen(ILogger<IsOpen> log)
        {
            _logger = log;
        }

        [FunctionName("IsOpen")]
        [OpenApiOperation(operationId: "IsOpen")]
        [OpenApiResponseWithBody(statusCode: HttpStatusCode.OK, contentType: "application/json", bodyType: typeof(bool), Description = "Check if the cafè is open")]
        public ActionResult<bool> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "OpeningHours/IsOpen")] HttpRequest req,
            ExecutionContext context)
        {
            _logger.LogInformation("IsOpen called");

            return new JsonResult(true);
        }
    }
}

