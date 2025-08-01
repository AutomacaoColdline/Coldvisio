using ColdvisioApi.Application.IService;
using Microsoft.AspNetCore.Mvc;

namespace ColdvisioApi.Presentation.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PlcsController : ControllerBase
    {
        private readonly IPlcService _plcService;

        public PlcsController(IPlcService plcService)
        {
            _plcService = plcService;
        }

        [HttpGet]
        public async Task<IActionResult> Get()
        {
            var plcs = await _plcService.GetAllAsync();
            return Ok(plcs);
        }
    }
}
