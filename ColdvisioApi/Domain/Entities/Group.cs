namespace ColdvisioApi.Domain.Entities
{
    public class Group
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public bool? CanRead { get; set; }
        public bool? CanWrite { get; set; }
    }
}
