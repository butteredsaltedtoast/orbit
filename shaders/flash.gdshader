shader_type canvas_item;

uniform float flash_amount: hint_range(0.0, 1.0) = 0.0;

void vertex() {
}

void fragment() {
	COLOR.rgb = mix(COLOR.rgb, vec3(1.0, 1.0, 1.0), flash_amount);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
