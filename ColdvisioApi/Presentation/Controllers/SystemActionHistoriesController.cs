using ColdvisioApi.Application.IService;
using Microsoft.AspNetCore.Mvc;

namespace ColdvisioApi.Presentation.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class SystemActionHistoriesController : ControllerBase
    {
        private readonly ISystemActionHistoryService _service;

        public SystemActionHistoriesController(ISystemActionHistoryService service)
        {
            _service = service;
        }

        [HttpGet]
        public async Task<IActionResult> Get()
        {
            var logs = await _service.GetAllAsync();
            return Ok(logs);
        }
    }
}
