using ColdvisioApi.Application.IService;
using ColdvisioApi.Domain.Entities;
using ColdvisioApi.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
public class GroupsService : IGroupsService
{
    private readonly AppDbContext _context;
    public GroupsService(AppDbContext context) => _context = context;

    public async Task<List<Group>> GetAllAsync() =>
        await _context.Groups.ToListAsync();
}
