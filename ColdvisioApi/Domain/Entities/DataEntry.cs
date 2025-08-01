namespace ColdvisioApi.Domain.Entities
{
    public class DataEntry
    {
        public int? Id { get; set; }
        public int? TypeData { get; set; }
        public string Offset { get; set; }
        public int? IdDevice { get; set; }
        public string Description { get; set; }
    }
}
