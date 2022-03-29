// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Ariaaaaa/FakePBR"
{
    Properties
    {
      [Header(Texture)]
        _MainTex ("MainTex A:AO",2D)="white"{}
        _BumpTex ("BumpTex",2D)="bump"{}
        _SpeTex ("SpeTex A:SpePow",2D)="gray"{}
        _EmitTex("EmitTex",2D)="black"{}
        _CubeMap ("CubeMap",Cube)="_Skybox"{}
     [Header(Glass)]
        _CubeMapLevel("CubeMapLevel",Range(1.0,10.0))=1.0
        _SpePow("SpePow",Range(1.0,30.0))=8.0
        _EnvIntensity("EnvIntensity",Range(0.0,20.0))=1.0
        _EmitIntensity("EmitIntensity",Range(0.0,10.0))=1.0
        _FresnelPow("FresnelPow",Range(1.0,30.0))=1.0
        _SpeInt("SpeInt",range(0.0,5.0))=0.2
     [Header(Color)]
        _MainColor("MainColor",Color)=(1.0,1.0,1.0,1.0)
        _TopColor("TopColor",Color)=(1.0,1.0,1.0,1.0)
        _SideColor("SideColor",Color)=(1.0,1.0,1.0,1.0)
        _DownColor("DownColor",Color)=(1.0,1.0,1.0,1.0)
    }
    SubShader
    {
        Pass
        {
            Tags
            {
                "LightMode"="ForwardBase"
                "RenderType"="Opaque"
            }

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase_fullshadow

            #include "AutoLight.cginc"
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            //贴图
            sampler2D _MainTex;
            sampler2D _BumpTex;
            sampler2D _SpeTex;
            sampler2D _EmitTex;
            samplerCUBE _CubeMap;


            //光泽度
            float _CubeMapLevel;
            float _SpePow;

            //环境影响程度
            float _EnvIntensity;
            float _EmitIntensity;
            float _FresnelPow;
            float _SpeInt;

            //颜色
            fixed4 _MainColor;
            fixed4 _TopColor;
            fixed4 _SideColor;
            fixed4 _DownColor;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 uv:TEXCOORD0;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                float3 worldPos:TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldTangent : TEXCOORD2;
                float3 worldBiTangent : TEXCOORD3;
                float2 uv:TEXCOORD4;
                LIGHTING_COORDS(5,6)
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
                o.worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));
                o.worldTangent = normalize(mul(unity_ObjectToWorld,v.tangent).xyz);
                o.worldBiTangent = normalize(cross(o.worldNormal,o.worldTangent)*v.tangent.w);
                TRANSFER_VERTEX_TO_FRAGMENT(o);
                o.uv = v.uv;
                return o;
            }

            float4 frag(v2f i):SV_Target
            {
                //准备向量
                float3 vDirWS = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float3 lDirWS = normalize(UnityWorldSpaceLightDir(i.worldPos));

                float3 nDirTS = UnpackNormal(tex2D(_BumpTex,i.uv));
                float3x3 TBN = float3x3(i.worldTangent,i.worldBiTangent,i.worldNormal);
                float3 nDirWS = mul(nDirTS,TBN);
                
                float3 vrDirWS = reflect(-vDirWS,nDirWS);

                //光照影响计算
                float nDotL = dot(lDirWS,nDirWS);
                float vrDotL = dot(vrDirWS,lDirWS);
                float nDotV = dot(vDirWS,nDirWS);

                //采样
                float4 mainTex = tex2D(_MainTex,i.uv);
                float3 emitTex = tex2D(_EmitTex,i.uv);
                float4 speTex = tex2D(_SpeTex,i.uv);
                float3 cubeTex = texCUBElod(_CubeMap,float4(vrDirWS,lerp(_CubeMapLevel,0,speTex.a))).rgb;


                //直接光照
                float3 baseColor = _MainColor.rgb * mainTex.rgb;
                float3 diffuse = baseColor * max(0,nDotL);
                float3 specular = speTex.rgb * pow(max(0,vrDotL),lerp(1.0,_SpePow,speTex.a));
                float shadow = LIGHT_ATTENUATION(i);
                float3 dirLight = (diffuse + specular) * shadow;

                //间接光照
                float top = max(0,nDirWS.g);
                float down = max(0,-nDirWS.g);
                float side = 1 - top - down;
                float3 envColor = _TopColor.rgb * top + _SideColor.rgb * side + _DownColor.rgb * down;
                float fresnel = pow(max(0.2,(1.0-nDotV)),_FresnelPow);
                float3 envLight = (envColor * baseColor * _EnvIntensity + cubeTex * fresnel * speTex.a * _SpeInt) * mainTex.a ;

                //自发光
                float3 emitColor = emitTex * _EmitIntensity;

                float3 finalColor = dirLight + envLight + emitColor;
                return float4(finalColor,1.0);
            }


            ENDCG
 
        }
    }
    FallBack "Diffuse"
}