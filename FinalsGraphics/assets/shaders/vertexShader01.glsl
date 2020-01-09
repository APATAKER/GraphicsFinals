#version 420

//uniform mat4 MVP;
uniform mat4 matModel;		// Model or World 
uniform mat4 matModelInverseTranspose;		// For normal calculation
uniform mat4 matView; 		// View or camera
uniform mat4 matProj;		// Projection transform

in vec4 vColour;				// Was vec3
in vec4 vPosition;				// Was vec3
in vec4 vNormal;				// Vertex normal
in vec4 vUVx2;					// 2 x Texture coords

//out vec3 color;
//out vec4 vertWorld;			// Location of the vertex in the world
out vec4 fColour;	
out vec4 fVertWorldLocation;
out vec4 fNormal;
out vec4 fUVx2;

uniform bool waterHeight;
uniform vec2 waterOffset;
uniform sampler2D waterSampler;

out vec2 fWaterOffset;

void main()
{
    vec4 vertPosition = vPosition;

	if ( waterHeight )
	{
		// Move the y value by some amount from texture	
		// Since it's black and white, I only sample 1 colour.
		
		vec2 texUV1 = vUVx2.st + waterOffset.xy;
		float texValue1 = texture( waterSampler, texUV1.st ).r;
		float ratio1 = 1.5;
		
		
		// This will pick a completely different location
		// (note the reversal of the xy to yx, called a "swizzle")
		vec2 texUV2 = vUVx2.st + waterOffset.yx * vec2(-0.5f, 0.75f);	
		float texValue2 = texture( waterSampler, texUV2.st ).r;
		float ratio2 = 2.5f;
		
		
		vertPosition.y += (texValue1*ratio1) + (texValue2 * ratio2);
	}
	
    mat4 matMVP = matProj * matView * matModel;
	
	gl_Position = matMVP * vec4(vertPosition.xyz, 1.0);
	
	// Vertex location in "world space"
	fVertWorldLocation = matModel * vec4(vertPosition.xyz, 1.0);	
	
	mat4 matModelInverseTranspose = inverse(transpose(matModel));
	
 	//fNormal = vNormal;

	vec3 theNormal = normalize(vNormal.xyz);
 	fNormal = matModelInverseTranspose * vec4(theNormal, 1.0f);
	
	// Pass the colour and UV unchanged.
    fColour = vColour;	
	fUVx2 = vUVx2;
	fWaterOffset = waterOffset;
}
