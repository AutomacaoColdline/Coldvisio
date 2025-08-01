using ColdvisioApi.Application.IService;
using ColdvisioApi.Domain.Entities;
using ColdvisioApi.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace ColdvisioApi.Infrastructure.Services
{
    public class PreventiveMaintenanceService : IPreventiveMaintenanceService
    {
        private readonly AppDbContext _context;

        public PreventiveMaintenanceService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<PreventiveMaintenance>> GetAllAsync()
        {
            return await _context.PreventiveMaintenances.ToListAsync();
        }
    }
}
