shader_type canvas_item;
uniform sampler2D noise_img : repeat_enable;
uniform float speed = 1.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 uv1 = vec2(UV.x + TIME * speed, UV.y);
	vec2 uv2 = vec2(UV.x, UV.y);
	vec2 uv3 = vec2(UV.x, UV.y + TIME * speed);
	float noise_r = texture(TEXTURE, UV).g;//texture(noise_img, uv1).r *1.8;
	float noise_g = texture(noise_img, uv2).g;
	float noise_b = texture(noise_img, uv3).b;
	
	vec3 new_color = vec3(noise_r, noise_g, noise_b);
	float new_alpha = noise_r * noise_g * noise_b;
	
	COLOR.rgb = new_color;
	//COLOR.rgb = texture(TEXTURE, UV).rgb;
	COLOR.a = clamp(new_alpha * 10.0 * texture(TEXTURE, UV).a, 0.0, 1.0);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
