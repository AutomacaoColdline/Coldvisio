using ColdvisioApi.Application.IService;
using ColdvisioApi.Domain.Entities;
using ColdvisioApi.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace ColdvisioApi.Infrastructure.Services
{
    public class DataCollectionService : IDataCollectionService
    {
        private readonly AppDbContext _context;

        public DataCollectionService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<DataCollection>> GetAllAsync()
        {
            return await _context.DataCollections.ToListAsync();
        }
    }
}
