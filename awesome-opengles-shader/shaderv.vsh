attribute vec4 a_position;
attribute vec2 a_textCoordinate;
varying lowp vec2 varyTextCoord;

void main()
{
    varyTextCoord = a_textCoordinate;
    gl_Position = a_position;
}
