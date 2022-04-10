Shader "Ariaaaaa/Rotate"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Opacity("Opacity",Range(0.0,1.0))=1.0
        _RotateRange("MoveRange",Range(0.0,90.0))=30.0
        _RotateSpeed("MoveSpeed",float)=1.0
    }
    SubShader
    {
        Tags 
        {
        "Queue"="Transparent"
        "RenderType"="TransparentCutout"
        "ForceNoShadowCasting"="True"
        "IgnoreProjector"="True"
        }
        Pass
        {
          Tags
          {
           "LightMode"="ForwardBase"
          }
          Blend One OneMinusSrcAlpha
          CGPROGRAM
          #pragma vertex vert
          #pragma fragment frag
          //#pragma multi_compile_fwdbase_fullshadow

          #include "UnityCG.cginc"
          #include "AutoLight.cginc"
          #include "Lighting.cginc"

          sampler2D _MainTex;

          half _Opacity;
          half _RotateRange;
          float  _RotateSpeed;

          #define TWO_PI 6.283185

          void Rotate(inout float3 vertex)
          {
             float angle = _RotateRange * sin(frac(_Time.y * _RotateSpeed)*TWO_PI);
             float radY = radians(angle);
             float cosY;
             float sinY;
             sincos(radY,sinY,cosY);
             vertex.xz = float2
             (
                vertex.x * cosY + vertex.z * sinY,
                vertex.x * -sinY + vertex.z * cosY
             );
          }

          struct a2v
          {
              float4 vertex:POSITION;
              float2 uv:TEXCOORD0;
          };

          struct v2f
          {
              float4 pos:SV_POSITION;
              float2 uv:TEXCOORD0;
          };

          v2f vert(a2v v)
          {
            v2f o;
            Rotate(v.vertex.xyz);
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.uv;
            return o;
          }

          float4 frag(v2f i):SV_Target
          {
            float4 mainTex = tex2D(_MainTex,i.uv);

            float3 finalColor = mainTex.rgb;

            float opacity = mainTex.a * _Opacity;


            return float4(finalColor * opacity,opacity);
          }
          ENDCG
        }
    }
}
