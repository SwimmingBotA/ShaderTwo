// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Ariaaaaa/TA 2"
{
    Properties
    {
      _BaseTex("BaseTex",2D)="white"{}
      _BumpTex("BumpTex",2D)="bump"{}
      _RampTex("RampTex",2D)="gray"{}
      _MaskeOne("B:  A:Emit",2D)="black"{}
      _MaskTwo("R:   G:   B:TintMask   A:  ",2D)="black"{}
      _FresnelWrap("FresnelWrap",2D)="black"{}
      _DiffuseWrap("DiffuseWrap",2D)="black"{}
      _CubeTex("CubeTex",Cube)="_Skybox"{}
      [Header(Color)]
       _EnvColor("EnvColor",Color)=(1.0,1.0,1.0,1.0)
       _RimColor("RimColor",Color)=(1.0,1.0,1.0,1.0)
       _EmtColor("EmtColor",Color)=(1.0,1.0,1.0,1.0)
      [Header(Intensity)]
       _SpeInt("SpeInt",Range(0.0,20.0))=1.0
       _EnvInt("EnvInt",Range(0.0,20.0))=1.0
       _EnvRefInt("EnvRefInt",Range(0.0,20.0))=1.0
       _RimInt("RimInt",Range(0.0,20.0))=1.0
       _EmitInt("EmitInt",Range(0.0,20.0))=1.0
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

            Cull Off

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase_fullshadow

            #include "AutoLight.cginc"
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            sampler2D _BaseTex;
            sampler2D _BumpTex;
            sampler2D _RampTex;
            sampler2D _MaskeOne;
            sampler2D _MaskTwo;
            sampler2D _FresnelWrap;
            sampler2D _DiffuseWrap;
            samplerCUBE _CubeTex;

            half4 _EnvColor;
            half4 _RimColor;
            half4 _EmtColor;


            half _SpeInt;
            half _EnvInt;
            half _EnvRefInt;
            half _RimInt;
            half _EmitInt;

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
                o.uv = v.uv;
                TRANSFER_VERTEX_TO_FRAGMENT(o);
                return o;
            }

            float4 frag(v2f i):SV_Target
            {
                half3 lDirWS = normalize(UnityWorldSpaceLightDir(i.worldPos));
                half3 vDirWS = normalize(UnityWorldSpaceViewDir(i.worldPos));
                half3 nDirTS = UnpackNormal(tex2D(_BumpTex,i.uv));
                half3x3 TBN = half3x3(i.worldTangent,i.worldBiTangent,i.worldNormal);
                half3 nDirWS = mul(nDirTS,TBN);
                half3 vrDirWS = reflect(-vDirWS,nDirWS);



                half3 baseColor = tex2D(_BaseTex,i.uv);
                half4 maskOne = tex2D(_MaskeOne,i.uv);
                half4 maskTwo = tex2D(_MaskTwo,i.uv);
                half3 fresnelWrap = tex2D(_FresnelWrap,half2(dot(vDirWS,nDirWS),0.2));
                
                half emitMask = maskOne.a;
                half cubeLevel = maskOne.b;
                half speInt = maskTwo.r;
                half rimMask = maskTwo.g;
                half speTint = maskTwo.b;
                half spePow = maskTwo.a;

                half3 cubeTex = texCUBElod(_CubeTex,float4(vrDirWS,lerp(8.0,0.0,cubeLevel)));
                //高光颜色
                half3 diffColor = lerp(baseColor,half3(0.0,0.0,0.0),speInt);
                half3 speColor = lerp(baseColor,half3(0.3,0.3,0.3),speTint)*speInt;


                //Fresnel
                half3 fresenl = lerp(fresnelWrap,0.0,rimMask);
                half fresnelColor = fresenl.r;
                half fresnelRim = fresenl.g;
                half fresnelSpe = fresenl.b;

                half halfLambert = dot(nDirWS,lDirWS)*0.5+0.5;
                half3 diffWarpTex = tex2D(_DiffuseWrap,half2(halfLambert,0.2));
                half3 diffuse = diffColor * halfLambert;

                half phong = pow(max(0.0,dot(vrDirWS,lDirWS)),spePow);
                half spec = phong * max(0,dot(nDirWS,lDirWS));
                spec = max(spec,fresnelSpe);
                half3 specular = speColor * spec * _SpeInt ;

                half shadow = LIGHT_ATTENUATION(i);

                //间接光
                half3 envDiff = diffColor * _EnvColor * _EnvInt;

                half reflectInt = max(fresnelSpe,speInt);
                half3 envRef = reflectInt * cubeTex * speColor * _EnvRefInt;

                half3 emitColor = emitMask * diffColor * _EmitInt * _EmtColor;

                half3 rimColor = max(0.0,nDirWS.g) * fresnelRim * _RimColor * _RimInt * speInt;


                float3 finalColor = (diffuse+specular)*shadow + envDiff + envRef + emitColor + rimColor;
               return float4(finalColor,1.0);
            }


            ENDCG
 
        }
    }
   
}