uniform sampler2D u_colorMap;
varying lowp vec2 varyTextCoord;

void main()
{
    gl_FragColor = texture2D(u_colorMap, varyTextCoord);
}
