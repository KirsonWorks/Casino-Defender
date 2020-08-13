// Screen space fx shader. 
// By Kirs-One.

shader_type canvas_item;

uniform int fade_type;

// 0. Color mixing.
// 1. Hole.
// 2. Curtain.
// 3. Reverse Curtain.

uniform vec4 color: hint_color;
uniform float blur : hint_range(0, 2);
uniform float grayscale: hint_range(0, 1);
uniform float fade_intensity: hint_range(0, 1);

void fragment()
{
	vec3 rgb = vec3(0.0);
	
	if (blur > 0.0)
	{
		rgb = textureLod(SCREEN_TEXTURE, SCREEN_UV, blur).rgb;
	}
	else 
	{
		rgb = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	}
	
	if (grayscale > 0.0)
	{
		vec3 gray = vec3((rgb.r * 0.2989) + (rgb.g * 0.5870) + (rgb.b * 0.1140));
		rgb = mix(rgb, gray, grayscale);
	}
	
	if (fade_type == 0) // Fading.
	{
		COLOR.rgb = mix(rgb, color.rgb, fade_intensity);
	}
	else if (fade_type == 1) // Hole.
	{
		vec2 ratio = vec2(1.0);
		ivec2 size = textureSize(SCREEN_TEXTURE, 0);
		
		if (size.x > size.y)
		{
			ratio.x = 1.0 / (float(size.y) / float(size.x));
		}
		else 
		{
			ratio.y = 1.0 / (float(size.x) / float(size.y));
		}
		
		if (distance(vec2(0.5) * ratio, SCREEN_UV * ratio) < 1.0 - fade_intensity)
		{
			COLOR.rgb = rgb;
		}
		else
		{
			COLOR.rgb = color.rgb;
		}
	}
	else if (fade_type == 2 || fade_type == 3) // Curtain and Curtain reverse.
	{
		bool from_texture = false;
		float angle = SCREEN_UV.y / 7.0;
		float px = SCREEN_UV.x - angle;
		
		if (fade_type == 2)
		{
			from_texture = px > fade_intensity;
		}
		else if (fade_type == 3)
		{
			from_texture = px < (1.0 - fade_intensity);
		}
		
		COLOR.rgb = from_texture ? rgb : color.rgb;
	}
}
