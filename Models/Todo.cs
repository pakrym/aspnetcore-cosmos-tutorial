using System;
using System.ComponentModel.DataAnnotations;
using Newtonsoft.Json;

namespace DotNetCoreSqlDb.Models
{
    public class Todo
    {
        [JsonProperty(PropertyName = "id")]
        public string Id { get; set; }
        public string Description { get; set; }

        [Display(Name = "Created Date")]
        [DataType(DataType.Date)]
        [DisplayFormat(DataFormatString = "{0:yyyy-MM-dd}", ApplyFormatInEditMode = true)]
        public DateTime CreatedDate { get; set; }
    }
}

