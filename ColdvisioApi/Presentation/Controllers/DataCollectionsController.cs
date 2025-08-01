using ColdvisioApi.Application.IService;
using Microsoft.AspNetCore.Mvc;

namespace ColdvisioApi.Presentation.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class DataCollectionsController : ControllerBase
    {
        private readonly IDataCollectionService _dataCollectionService;

        public DataCollectionsController(IDataCollectionService dataCollectionService)
        {
            _dataCollectionService = dataCollectionService;
        }

        [HttpGet]
        public async Task<IActionResult> Get()
        {
            var collections = await _dataCollectionService.GetAllAsync();
            return Ok(collections);
        }
    }
}
