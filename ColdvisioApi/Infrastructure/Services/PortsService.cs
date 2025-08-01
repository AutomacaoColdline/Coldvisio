using ColdvisioApi.Application.IService;
using ColdvisioApi.Domain.Entities;
using ColdvisioApi.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace ColdvisioApi.Infrastructure.Services
{
    public class PortsService : IPortsService
    {
        private readonly AppDbContext _context;

        public PortsService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<Port>> GetAllAsync()
        {
            return await _context.Ports.ToListAsync();
        }
    }
}
