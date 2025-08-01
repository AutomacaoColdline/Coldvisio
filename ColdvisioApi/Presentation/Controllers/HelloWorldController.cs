using Microsoft.AspNetCore.Mvc;
using ColdvisioApi.Application.IService;

namespace ColdvisioApi.Presentation.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class HelloWorldController : ControllerBase
    {
        private readonly IHelloWorldService _helloWorldService;

        public HelloWorldController(IHelloWorldService helloWorldService)
        {
            _helloWorldService = helloWorldService;
        }

        [HttpGet]
        public IActionResult Get()
        {
            var message = _helloWorldService.GetMessage();
            return Ok(message);
        }
    }
}
