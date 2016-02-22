varying mediump vec4 varyingColor;
varying mediump vec3 varyingNormal;
uniform sampler2D DIFFUSE;
varying mediump vec2 varyingTexcoord0;
void main()
{
    gl_FragColor = texture2D(DIFFUSE,varyingTexcoord0);// + vec4(varyingNormal* 0.3,1) + vec4(0.1);
}
