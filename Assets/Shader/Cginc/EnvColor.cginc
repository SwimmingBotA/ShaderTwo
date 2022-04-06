#ifndef EnvColor
#define EnvColor

float3 ThreeColor(float n, float3 _TopColor, float3 _SideColor, float3 _DownColor)
{
    float top = max(0, n);
    float down = max(0, -n);
    float side = 1 - top - down;
    float3 envColor = _TopColor.rgb * top + _SideColor.rgb * side + _DownColor.rgb * down;
    return envColor;
}

#endif