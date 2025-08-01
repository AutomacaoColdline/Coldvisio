namespace ColdvisioApi.Domain.Entities
{
    public class User
    {
        public string Id { get; set; }
        public string FullName { get; set; }
        public string PhoneNumber { get; set; }
        public DateTime? BirthDate { get; set; }
        public DateTime CreatedAt { get; set; }
        public string Group { get; set; }

        public string EmailSend1 { get; set; }
        public string EmailSend2 { get; set; }
        public string EmailSend3 { get; set; }
    }
}
