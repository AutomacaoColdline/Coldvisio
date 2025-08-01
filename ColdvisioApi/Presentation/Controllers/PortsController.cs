using ColdvisioApi.Application.IService;
using Microsoft.AspNetCore.Mvc;

namespace ColdvisioApi.Presentation.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PortsController : ControllerBase
    {
        private readonly IPortsService _portsService;

        public PortsController(IPortsService portsService)
        {
            _portsService = portsService;
        }

        [HttpGet]
        public async Task<IActionResult> Get()
        {
            var ports = await _portsService.GetAllAsync();
            return Ok(ports);
        }
    }
}
