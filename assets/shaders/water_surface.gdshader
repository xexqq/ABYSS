// ABYSS water surface — mobile-friendly wave shader.
// Vertex waves (analytic normals), fresnel color mixing, sun specular.
shader_type spatial;
render_mode blend_mix, depth_draw_never, cull_disabled, specular_schlick_ggx;

uniform float wave_height : hint_range(0.0, 1.5) = 0.35;
uniform float wave_speed : hint_range(0.0, 4.0) = 0.9;
uniform float wave_frequency : hint_range(0.01, 0.5) = 0.06;
uniform vec4 shallow_color : source_color = vec4(0.086, 0.42, 0.52, 0.75);
uniform vec4 deep_color : source_color = vec4(0.0, 0.06, 0.11, 0.97);
uniform float depth_fade_distance : hint_range(1.0, 200.0) = 40.0;
uniform float surface_glow : hint_range(0.0, 1.0) = 0.12;

void vertex() {
	float t = TIME * wave_speed;
	vec2 p = VERTEX.xz;
	float f = wave_frequency;
	// Layered waves (no expensive loops).
	float h = 0.0;
	h += sin(p.x * f + t * 1.00) * 0.50;
	h += sin(p.y * f * 1.31 - t * 0.83) * 0.35;
	h += sin((p.x + p.y) * f * 0.71 + t * 1.41) * 0.28;
	h += sin((p.x * 0.7 - p.y) * f * 1.87 - t * 1.13) * 0.17;
	VERTEX.y = h * wave_height;
	// Analytic partial derivatives for stable normal.
	float dx = 0.50 * f * cos(p.x * f + t * 1.00)
		+ 0.28 * 0.71 * f * cos((p.x + p.y) * f * 0.71 + t * 1.41)
		+ 0.17 * 1.87 * 0.7 * f * cos((p.x * 0.7 - p.y) * f * 1.87 - t * 1.13);
	float dz = 0.35 * f * 1.31 * cos(p.y * f * 1.31 - t * 0.83)
		+ 0.28 * 0.71 * f * cos((p.x + p.y) * f * 0.71 + t * 1.41)
		- 0.17 * 1.87 * f * cos((p.x * 0.7 - p.y) * f * 1.87 - t * 1.13);
	NORMAL = normalize(vec3(-dx, 1.0, -dz));
}

void fragment() {
	float fres = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 3.0);
	vec4 col = mix(deep_color, shallow_color, fres);
	ALBEDO = col.rgb;
	ALPHA = col.a;
	ROUGHNESS = 0.02;
	SPECULAR = 0.65;
	EMISSION = col.rgb * surface_glow * fres;
}
