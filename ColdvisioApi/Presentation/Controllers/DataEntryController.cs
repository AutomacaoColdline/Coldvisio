using ColdvisioApi.Application.IService;
using Microsoft.AspNetCore.Mvc;

namespace ColdvisioApi.Presentation.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class DataEntryController : ControllerBase
    {
        private readonly IDataEntryService _dataEntryService;

        public DataEntryController(IDataEntryService dataEntryService)
        {
            _dataEntryService = dataEntryService;
        }

        [HttpGet]
        public async Task<IActionResult> Get()
        {
            var data = await _dataEntryService.GetAllAsync();
            return Ok(data);
        }
    }
}
