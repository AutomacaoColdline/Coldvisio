using ColdvisioApi.Application.IService;
using Microsoft.AspNetCore.Mvc;

namespace ColdvisioApi.Presentation.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class DeviceControllersController : ControllerBase
    {
        private readonly IDeviceControllerService _deviceControllerService;

        public DeviceControllersController(IDeviceControllerService DeviceControllerService)
        {
            _deviceControllerService = DeviceControllerService;
        }

        [HttpGet]
        public async Task<IActionResult> Get()
        {
            var DeviceControllers = await _deviceControllerService.GetAllAsync();
            return Ok(DeviceControllers);
        }
    }
}
