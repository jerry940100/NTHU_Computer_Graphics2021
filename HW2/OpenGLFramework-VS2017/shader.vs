#version 330 core

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aColor;
layout (location = 2) in vec3 aNormal;

out vec3 vertex_color;
out vec3 vertex_normal;
out vec3 FragPos;


uniform mat4 mvp;
uniform mat4 mv;
uniform mat4 view_matrix;
uniform int lightIdx;
uniform vec3 Ka;
uniform vec3 Kd;
uniform vec3 Ks;
uniform float shininess;
uniform vec3 La = vec3(0.15f, 0.15f, 0.15f);
uniform vec3 Ld1;
uniform vec3 Ld2;
uniform vec3 Ld3;
uniform vec3 lightPos1;
uniform vec3 lightPos2;
uniform vec3 lightPos3;
uniform float spotCutoff;
uniform int perpix;

//three lights are different in Attenuation
vec3 directlight(){
	//dot normalized vector can calculate cosine(theta)
	vec3 N = normalize(vertex_normal);
	vec4 lightInView =  view_matrix * vec4(lightPos1,1.0);
	vec3 L = normalize(lightInView.xyz - FragPos);
	vec3 V = normalize(-FragPos);	//camera vector
	vec3 H = normalize(L+V);
	vec3 ambient = La*Ka;
	vec3 diffuse = Kd * max(dot(N, L), 0);
	vec3 specular = Ks * pow(max(dot(N, H), 0), shininess);
	vec3 color = ambient +Ld1*( diffuse + specular);
	return color;
}
vec3 pointlight(){
	vec3 N = normalize(vertex_normal);
	vec4 lightInView =  view_matrix * vec4(lightPos2,1.0);
	vec3 L = normalize(lightInView.xyz - FragPos);
	vec3 V = normalize(-FragPos);	//camera vector
	vec3 H = normalize(L+V);
	float dist = length(lightPos2 - FragPos);
	float cal = 0.01 + 0.8 * dist + 0.1 * dist * dist;
	float factor = 1/(cal);
	vec3 ambient = La * Ka;
	vec3 diffuse =  Kd * max(dot(N, L), 0);
	vec3 specular = Ks * pow(max(dot(N, H), 0), shininess);
	vec3 color = ambient + factor*Ld2*(diffuse + specular);
	return color;
}
vec3 spotlight(){
	vec3 N = normalize(vertex_normal);
	vec4 lightInView =  view_matrix * vec4(lightPos3,1.0);
	vec3 L = normalize(lightInView.xyz - FragPos);
	vec3 V = normalize(-FragPos);	//camera vector
	vec3 H = normalize(L+V);
	vec4 spotdirection = vec4(0.0f, 0.0f,-1.0f,1.0f);
	vec3 direction = normalize((transpose(inverse(view_matrix))*spotdirection).xyz);
	float spot = dot(-L, direction);

	float dist = length(lightInView.xyz - FragPos);
	float cal = 0.05 + 0.3 * dist + 0.6 * dist * dist;
	float factor = 1/cal;

	vec3 ambient = La * Ka;
	vec3 diffuse =  Kd * max(dot(N, L), 0);
	vec3 specular = Ks * pow(max(dot(N, H), 0), shininess);
	//theta in the cutoff should be lighted
	if(spotCutoff > degrees(acos(spot))){
		vec3 color=ambient+factor* pow(max(spot, 0), 50) * Ld3*(diffuse + specular);
		return color;
	}
	else{
		vec3 color=ambient+factor*0*(diffuse + specular);
		return color;
	}
}
void main()
{
	// [TODO]
	vec4 vertexInView = mv*vec4(aPos.x, aPos.y, aPos.z, 1.0);
	vertex_normal = mat3(transpose(inverse(mv))) * aNormal;
	//vertex_normal =  (transpose(inverse(mv)) * vec4(aNormal, 0.0)).xyz;
	FragPos = vertexInView.xyz;
	gl_Position = mvp*vec4(aPos.x, aPos.y, aPos.z, 1.0);
	vec3 color = vec3(0,0,0);
	if(perpix==0){
		if(lightIdx%3==0){
			color+=directlight();
		}
		else if(lightIdx%3==1){
			color+=pointlight();
		}
		else if(lightIdx%3==2){
			color += spotlight();
		}
	}

	vertex_color = color*aColor;
}

