using ColdvisioApi.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace ColdvisioApi.Infrastructure.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<User> Users { get; set; }
        public DbSet<Group> Groups { get; set; }
        public DbSet<Port> Ports { get; set; }
        public DbSet<DataEntry> DataEntry { get; set; } 
        public DbSet<DataCollection> DataCollections { get; set; }
        public DbSet<DeviceController> DeviceControllers { get; set; }
        public DbSet<Plc> Plcs { get; set; }
        public DbSet<PreventiveMaintenance> PreventiveMaintenances { get; set; }
        public DbSet<Rate> Rates { get; set; }
        public DbSet<SystemActionHistory> SystemActionHistories { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // DeviceController 
            modelBuilder.Entity<DeviceController>().ToTable("devicecontroller").HasNoKey();
            modelBuilder.Entity<DeviceController>().Property(p => p.Name).HasColumnName("name");
            modelBuilder.Entity<DeviceController>().Property(p => p.SerialNumber).HasColumnName("serial_number");
            modelBuilder.Entity<DeviceController>().Property(p => p.Model).HasColumnName("model");
            modelBuilder.Entity<DeviceController>().Property(p => p.Address).HasColumnName("address");

            // User
            modelBuilder.Entity<User>().ToTable("Users");
            modelBuilder.Entity<User>().Property(p => p.Id).HasColumnName("id");
            modelBuilder.Entity<User>().Property(p => p.FullName).HasColumnName("full_name");
            modelBuilder.Entity<User>().Property(p => p.PhoneNumber).HasColumnName("phone_number");
            modelBuilder.Entity<User>().Property(p => p.BirthDate).HasColumnName("birth_date");
            modelBuilder.Entity<User>().Property(p => p.CreatedAt).HasColumnName("created_at");
            modelBuilder.Entity<User>().Property(p => p.Group).HasColumnName("group_id");
            modelBuilder.Entity<User>().Property(p => p.EmailSend1).HasColumnName("email_send_1");
            modelBuilder.Entity<User>().Property(p => p.EmailSend2).HasColumnName("email_send_2");
            modelBuilder.Entity<User>().Property(p => p.EmailSend3).HasColumnName("email_send_3");

            // Group
            modelBuilder.Entity<Group>().ToTable("group");
            modelBuilder.Entity<Group>().Property(p => p.Id).HasColumnName("id");
            modelBuilder.Entity<Group>().Property(p => p.Name).HasColumnName("name");
            modelBuilder.Entity<Group>().Property(p => p.CanRead).HasColumnName("canread");
            modelBuilder.Entity<Group>().Property(p => p.CanWrite).HasColumnName("canwrite");

            // Port
            modelBuilder.Entity<Port>().ToTable("Port");
            modelBuilder.Entity<Port>().Property(p => p.Id).HasColumnName("id");
            modelBuilder.Entity<Port>().Property(p => p.Name).HasColumnName("name");
            modelBuilder.Entity<Port>().Property(p => p.Status).HasColumnName("status");

            // Data
            modelBuilder.Entity<DataEntry>().ToTable("data");
            modelBuilder.Entity<DataEntry>().Property(p => p.Id).HasColumnName("id");
            modelBuilder.Entity<DataEntry>().Property(p => p.TypeData).HasColumnName("type_data");
            modelBuilder.Entity<DataEntry>().Property(p => p.Offset).HasColumnName("offset_");
            modelBuilder.Entity<DataEntry>().Property(p => p.IdDevice).HasColumnName("id_device");
            modelBuilder.Entity<DataEntry>().Property(p => p.Description).HasColumnName("description");

            // DataCollection
            modelBuilder.Entity<DataCollection>().ToTable("datacollection");
            modelBuilder.Entity<DataCollection>().Property(p => p.Id).HasColumnName("id");
            modelBuilder.Entity<DataCollection>().Property(p => p.InsertTimestamp).HasColumnName("insert_timestamp");
            modelBuilder.Entity<DataCollection>().Property(p => p.DataTimestamp).HasColumnName("data_timestamp");
            modelBuilder.Entity<DataCollection>().Property(p => p.DataId).HasColumnName("data_id");
            modelBuilder.Entity<DataCollection>().Property(p => p.DataType).HasColumnName("data_type");
            modelBuilder.Entity<DataCollection>().Property(p => p.DataOffset).HasColumnName("data_offset");
            modelBuilder.Entity<DataCollection>().Property(p => p.DataBool).HasColumnName("data_bool");
            modelBuilder.Entity<DataCollection>().Property(p => p.DataInt).HasColumnName("data_int");
            modelBuilder.Entity<DataCollection>().Property(p => p.DataReal).HasColumnName("data_real");
            modelBuilder.Entity<DataCollection>().Property(p => p.Dint).HasColumnName("dint");
            modelBuilder.Entity<DataCollection>().Property(p => p.Uint).HasColumnName("uint");
            modelBuilder.Entity<DataCollection>().Property(p => p.Udint).HasColumnName("udint");
            modelBuilder.Entity<DataCollection>().Property(p => p.IdDevice).HasColumnName("id_device");
            modelBuilder.Entity<DataCollection>().Property(p => p.NameDevice).HasColumnName("name_device");
            modelBuilder.Entity<DataCollection>().Property(p => p.ModelDevice).HasColumnName("model_device");
            modelBuilder.Entity<DataCollection>().Property(p => p.AddressDevice).HasColumnName("address_device");
            modelBuilder.Entity<DataCollection>().Property(p => p.StatusPlc).HasColumnName("status_plc");

            // Plc
            modelBuilder.Entity<Plc>().ToTable("plc");
            modelBuilder.Entity<Plc>().Property(p => p.Id).HasColumnName("id");
            modelBuilder.Entity<Plc>().Property(p => p.DeviceName).HasColumnName("device_name");
            modelBuilder.Entity<Plc>().Property(p => p.Ip).HasColumnName("ip");
            modelBuilder.Entity<Plc>().Property(p => p.Gateway).HasColumnName("gateway");
            modelBuilder.Entity<Plc>().Property(p => p.SubnetMask).HasColumnName("subnet_mask");
            modelBuilder.Entity<Plc>().Property(p => p.Status).HasColumnName("status");

            // PreventiveMaintenance
            modelBuilder.Entity<PreventiveMaintenance>().ToTable("preventivemaintenance");
            modelBuilder.Entity<PreventiveMaintenance>().Property(p => p.Id).HasColumnName("id");
            modelBuilder.Entity<PreventiveMaintenance>().Property(p => p.DeviceControllerName).HasColumnName("device_controller_name");
            modelBuilder.Entity<PreventiveMaintenance>().Property(p => p.DeviceControllerAddress).HasColumnName("device_controller_address");
            modelBuilder.Entity<PreventiveMaintenance>().Property(p => p.DataTimestamp).HasColumnName("data_timestamp");
            modelBuilder.Entity<PreventiveMaintenance>().Property(p => p.Notice).HasColumnName("notice");
            modelBuilder.Entity<PreventiveMaintenance>().Property(p => p.Alert).HasColumnName("alert");

            // Rate
            modelBuilder.Entity<Rate>().ToTable("rates");
            modelBuilder.Entity<Rate>().Property(p => p.Id).HasColumnName("id");
            modelBuilder.Entity<Rate>().Property(p => p.DeviceControllerAddress).HasColumnName("device_controller_adress");
            modelBuilder.Entity<Rate>().Property(p => p.Date).HasColumnName("date");
            modelBuilder.Entity<Rate>().Property(p => p.DeviceControllerName).HasColumnName("device_controller_name");
            modelBuilder.Entity<Rate>().Property(p => p.Status).HasColumnName("status");
            modelBuilder.Entity<Rate>().Property(p => p.ComunicacaoOk).HasColumnName("comunicacao_ok");
            modelBuilder.Entity<Rate>().Property(p => p.ComunicacaoNok).HasColumnName("comunicacao_nok");
            modelBuilder.Entity<Rate>().Property(p => p.Timestamp).HasColumnName("timestamp");

            // SystemActionHistory
            modelBuilder.Entity<SystemActionHistory>().ToTable("systemactionhistory").HasNoKey();
            modelBuilder.Entity<SystemActionHistory>().Property(p => p.EventName).HasColumnName("event_name");
            modelBuilder.Entity<SystemActionHistory>().Property(p => p.EventType).HasColumnName("event_type");
            modelBuilder.Entity<SystemActionHistory>().Property(p => p.TagName).HasColumnName("tag_name");
            modelBuilder.Entity<SystemActionHistory>().Property(p => p.Origin).HasColumnName("origin");
            modelBuilder.Entity<SystemActionHistory>().Property(p => p.Model).HasColumnName("model");
            modelBuilder.Entity<SystemActionHistory>().Property(p => p.Timestamp).HasColumnName("timestamp");
            modelBuilder.Entity<SystemActionHistory>().Property(p => p.TagValue).HasColumnName("tag_value");
            modelBuilder.Entity<SystemActionHistory>().Property(p => p.LoggedUser).HasColumnName("logged_user");
            modelBuilder.Entity<SystemActionHistory>().Property(p => p.Message).HasColumnName("message");
            modelBuilder.Entity<SystemActionHistory>().Property(p => p.TriggerValue).HasColumnName("trigger_value");
            modelBuilder.Entity<SystemActionHistory>().Property(p => p.Priority).HasColumnName("priority");
            modelBuilder.Entity<SystemActionHistory>().Property(p => p.AlarmGroup).HasColumnName("alarm_group");
            modelBuilder.Entity<SystemActionHistory>().Property(p => p.Area).HasColumnName("area");
            modelBuilder.Entity<SystemActionHistory>().Property(p => p.SessionId).HasColumnName("session_id");
            modelBuilder.Entity<SystemActionHistory>().Property(p => p.AlarmTransitionAlarmTransition).HasColumnName("alarm_transitionalarm_transition");
        }
    }
}
