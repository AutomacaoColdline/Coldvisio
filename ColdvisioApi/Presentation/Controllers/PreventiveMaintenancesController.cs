using ColdvisioApi.Application.IService;
using Microsoft.AspNetCore.Mvc;

namespace ColdvisioApi.Presentation.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PreventiveMaintenancesController : ControllerBase
    {
        private readonly IPreventiveMaintenanceService _service;

        public PreventiveMaintenancesController(IPreventiveMaintenanceService service)
        {
            _service = service;
        }

        [HttpGet]
        public async Task<IActionResult> Get()
        {
            var data = await _service.GetAllAsync();
            return Ok(data);
        }
    }
}
