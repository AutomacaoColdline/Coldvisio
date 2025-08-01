using ColdvisioApi.Application.IService;
using ColdvisioApi.Domain.Entities;
using ColdvisioApi.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace ColdvisioApi.Infrastructure.Services
{
    public class DeviceControllerService : IDeviceControllerService
    {
        private readonly AppDbContext _context;

        public DeviceControllerService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<DeviceController>> GetAllAsync()
        {
            return await _context.DeviceControllers.ToListAsync();
        }
    }
}
