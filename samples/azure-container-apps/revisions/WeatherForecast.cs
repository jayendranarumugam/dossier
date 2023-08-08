using System.Text.Json.Serialization;

namespace revisions;

public class WeatherForecast
{
    public DateOnly Date { get; set; }

    public int Temperature { get; set; }

    [JsonConverter(typeof(JsonStringEnumConverter))]
    public TemperatureUnit? TemperatureUnit { get; set; }

    [JsonIgnore]
    public int TemperatureC { get; set; }

    [JsonIgnore]
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);

    public string? Summary { get; set; }
}

public enum TemperatureUnit {
    Fahrenheit,
    Celcius
}
