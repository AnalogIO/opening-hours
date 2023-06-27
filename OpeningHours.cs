using System.Collections.Generic;
using System.IO;
using System.Net;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Azure.WebJobs.Extensions.OpenApi.Core.Attributes;
using Microsoft.Extensions.Logging;
using Microsoft.OpenApi.Models;
using Models;
using Newtonsoft.Json;

namespace OpeningHours
{
    public class OpeningHours
    {
        private readonly ILogger<OpeningHours> _logger;

        public OpeningHours(ILogger<OpeningHours> log)
        {
            _logger = log;
        }

        [FunctionName("OpeningHours")]
        [OpenApiOperation(operationId: "OpeningHours")]
        [OpenApiResponseWithBody(statusCode: HttpStatusCode.OK, contentType: "application/json", bodyType: typeof(Dictionary<string, Day>), Description = "Get the opening hours for the cafè")]
        public ActionResult<Dictionary<string, Day>> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "OpeningHours")] HttpRequest req, 
            ExecutionContext context )
        {
            _logger.LogInformation("OpeningHours called");

            var path = Path.Combine(context.FunctionAppDirectory, "Files", "openinghours.json");

            var json = File.ReadAllText(path);

            var schedule = JsonConvert.DeserializeObject<Schedule>(json);

            return new JsonResult(schedule.schedule);
        }
    }
}

