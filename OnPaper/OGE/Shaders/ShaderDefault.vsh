attribute vec3 position;
attribute vec3 normal;
attribute vec2 texcoord0;

uniform mat4 ModelViewProjectionMatrix;

varying mediump vec4 varyingColor;
varying mediump vec3 varyingNormal;
varying mediump vec2 varyingTexcoord0;

void main()
{
    gl_Position = ModelViewProjectionMatrix * vec4(position,1.0);
    varyingColor = vec4(0.5,0.2,0.7,1.0);
    varyingNormal = normal;
    varyingTexcoord0 = texcoord0;
}
