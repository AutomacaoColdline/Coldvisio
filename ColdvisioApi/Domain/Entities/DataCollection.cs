namespace ColdvisioApi.Domain.Entities
{
    public class DataCollection
    {
        public int Id { get; set; }
        public DateTime? InsertTimestamp { get; set; }
        public DateTime? DataTimestamp { get; set; }
        public int? DataId { get; set; }
        public int? DataType { get; set; }
        public string DataOffset { get; set; }
        public bool? DataBool { get; set; }
        public int? DataInt { get; set; }
        public float? DataReal { get; set; }
        public int? Dint { get; set; }
        public int? Uint { get; set; }
        public int? Udint { get; set; }
        public int? IdDevice { get; set; }
        public string NameDevice { get; set; }
        public int? ModelDevice { get; set; }
        public int? AddressDevice { get; set; }
        public int? StatusPlc { get; set; }
    }
}
