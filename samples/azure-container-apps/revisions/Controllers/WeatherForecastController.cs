using Microsoft.AspNetCore.Mvc;

namespace revisions.Controllers;

[ApiController]
[Route("[controller]")]
public class WeatherForecastController : ControllerBase
{
    private static readonly string[] Summaries = new[]
    {
        "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
    };

    private readonly ILogger<WeatherForecastController> _logger;

    public WeatherForecastController(ILogger<WeatherForecastController> logger)
    {
        _logger = logger;
    }

    [HttpGet(Name = "GetWeatherForecast")]
    public IEnumerable<WeatherForecast> Get()
    {
        return Enumerable.Range(1, 5).Select(index => {
            var wf = new WeatherForecast
            {
                Date = DateOnly.FromDateTime(DateTime.Now.AddDays(index)),           
                TemperatureC = Random.Shared.Next(-20, 55),
                Summary = Summaries[Random.Shared.Next(Summaries.Length)]
            };

            switch (Enum.Parse<TemperatureUnit>(Environment.GetEnvironmentVariable("DESIRED_TEMP_UNIT") ?? "Fahrenheit"))
            {   
                case TemperatureUnit.Celcius:
                    wf.Temperature = wf.TemperatureC;
                    wf.TemperatureUnit = TemperatureUnit.Celcius;
                    break;
                default:
                case TemperatureUnit.Fahrenheit:
                    wf.Temperature = wf.TemperatureF;
                    wf.TemperatureUnit = TemperatureUnit.Fahrenheit;
                    break;
            }

            return wf;
        })
        .ToArray();
    }
}
