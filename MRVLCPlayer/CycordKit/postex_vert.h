"#version 100 \n\
attribute highp vec2 a_position;     \n\
attribute highp vec2 a_texCoord;     \n\
     \n\
varying highp vec2 v_texCoord;     \n\
     \n\
void main(void) {     \n\
    gl_Position = vec4(a_position.xy, 0.0, 1.0);     \n\
\n\
    v_texCoord = a_texCoord;     \n\
}     \n\
"
