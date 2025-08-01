using ColdvisioApi.Application.IService;
using Microsoft.AspNetCore.Mvc;

namespace ColdvisioApi.Presentation.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class RatesController : ControllerBase
    {
        private readonly IRatesService _ratesService;

        public RatesController(IRatesService ratesService)
        {
            _ratesService = ratesService;
        }

        [HttpGet]
        public async Task<IActionResult> Get()
        {
            var rates = await _ratesService.GetAllAsync();
            return Ok(rates);
        }
    }
}
