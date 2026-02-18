Shader "Custom/TerrainURPLitHeightBlend"
{
    Properties
    {
        [Header(Layer 0)]
        _Splat0 ("Layer 0 (Albedo)", 2D) = "white" {}
        _Normal0 ("Layer 0 (Normal)", 2D) = "bump" {}
        _Height0 ("Layer 0 (Height)", 2D) = "gray" {}
        _Metallic0 ("Layer 0 Metallic", Range(0, 1)) = 0
        _Smoothness0 ("Layer 0 Smoothness", Range(0, 1)) = 0.5
        
        [Header(Layer 1)]
        _Splat1 ("Layer 1 (Albedo)", 2D) = "white" {}
        _Normal1 ("Layer 1 (Normal)", 2D) = "bump" {}
        _Height1 ("Layer 1 (Height)", 2D) = "gray" {}
        _Metallic1 ("Layer 1 Metallic", Range(0, 1)) = 0
        _Smoothness1 ("Layer 1 Smoothness", Range(0, 1)) = 0.5
        
        [Header(Layer 2)]
        _Splat2 ("Layer 2 (Albedo)", 2D) = "white" {}
        _Normal2 ("Layer 2 (Normal)", 2D) = "bump" {}
        _Height2 ("Layer 2 (Height)", 2D) = "gray" {}
        _Metallic2 ("Layer 2 Metallic", Range(0, 1)) = 0
        _Smoothness2 ("Layer 2 Smoothness", Range(0, 1)) = 0.5
        
        [Header(Layer 3)]
        _Splat3 ("Layer 3 (Albedo)", 2D) = "white" {}
        _Normal3 ("Layer 3 (Normal)", 2D) = "bump" {}
        _Height3 ("Layer 3 (Height)", 2D) = "gray" {}
        _Metallic3 ("Layer 3 Metallic", Range(0, 1)) = 0
        _Smoothness3 ("Layer 3 Smoothness", Range(0, 1)) = 0.5
        
        [Header(Control)]
        _Control ("Control (RGBA)", 2D) = "red" {}
        
        [Header(Height Blend Settings)]
        _HeightBlendStrength ("Height Blend Strength", Range(0, 1)) = 0.5
        _HeightTransition ("Height Transition", Range(0.01, 1)) = 0.2
        
        [Header(Tiling)]
        _Tiling ("Tiling", Float) = 1
    }
    
    SubShader
    {
        Tags 
        { 
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "Queue" = "Geometry"
        }
        
        LOD 200
        
        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fog
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            
            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 uv : TEXCOORD0;
            };
            
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                float3 normalWS : TEXCOORD2;
                float4 tangentWS : TEXCOORD3;
                float3 viewDirWS : TEXCOORD4;
                float fogFactor : TEXCOORD5;
            };
            
            // Textures and samplers
            TEXTURE2D(_Control); SAMPLER(sampler_Control);
            
            TEXTURE2D(_Splat0); SAMPLER(sampler_Splat0);
            TEXTURE2D(_Splat1); SAMPLER(sampler_Splat1);
            TEXTURE2D(_Splat2); SAMPLER(sampler_Splat2);
            TEXTURE2D(_Splat3); SAMPLER(sampler_Splat3);
            
            TEXTURE2D(_Normal0); SAMPLER(sampler_Normal0);
            TEXTURE2D(_Normal1); SAMPLER(sampler_Normal1);
            TEXTURE2D(_Normal2); SAMPLER(sampler_Normal2);
            TEXTURE2D(_Normal3); SAMPLER(sampler_Normal3);
            
            TEXTURE2D(_Height0); SAMPLER(sampler_Height0);
            TEXTURE2D(_Height1); SAMPLER(sampler_Height1);
            TEXTURE2D(_Height2); SAMPLER(sampler_Height2);
            TEXTURE2D(_Height3); SAMPLER(sampler_Height3);
            
            CBUFFER_START(UnityPerMaterial)
                float4 _Control_ST;
                float4 _Splat0_ST;
                float _Metallic0, _Smoothness0;
                float _Metallic1, _Smoothness1;
                float _Metallic2, _Smoothness2;
                float _Metallic3, _Smoothness3;
                float _HeightBlendStrength;
                float _HeightTransition;
                float _Tiling;
            CBUFFER_END
            
            // Height-based blending function
            float4 HeightBlend(float4 weights, float h0, float h1, float h2, float h3)
            {
                float4 heights = float4(h0, h1, h2, h3);
                
                // Add height influence to weights
                heights *= _HeightBlendStrength;
                float4 blendWeights = weights + heights;
                
                // Normalize weights
                float maxHeight = max(max(blendWeights.x, blendWeights.y), max(blendWeights.z, blendWeights.w));
                blendWeights = max(blendWeights - maxHeight + _HeightTransition, 0);
                
                float sumWeights = blendWeights.x + blendWeights.y + blendWeights.z + blendWeights.w;
                return blendWeights / max(sumWeights, 0.0001);
            }
            
            Varyings vert(Attributes input)
            {
                Varyings output;
                
                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                
                output.positionCS = vertexInput.positionCS;
                output.positionWS = vertexInput.positionWS;
                output.normalWS = normalInput.normalWS;
                output.tangentWS = float4(normalInput.tangentWS, input.tangentOS.w);
                output.viewDirWS = GetWorldSpaceViewDir(vertexInput.positionWS);
                output.uv = input.uv;
                output.fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
                
                return output;
            }
            
            half4 frag(Varyings input) : SV_Target
            {
                // Sample control map
                float4 controlWeights = SAMPLE_TEXTURE2D(_Control, sampler_Control, input.uv);
                
                // Calculate tiled UVs
                float2 tiledUV = input.uv * _Tiling;
                
                // Sample height maps
                float height0 = SAMPLE_TEXTURE2D(_Height0, sampler_Height0, tiledUV).r;
                float height1 = SAMPLE_TEXTURE2D(_Height1, sampler_Height1, tiledUV).r;
                float height2 = SAMPLE_TEXTURE2D(_Height2, sampler_Height2, tiledUV).r;
                float height3 = SAMPLE_TEXTURE2D(_Height3, sampler_Height3, tiledUV).r;
                
                // Calculate height-based blend weights
                float4 blendWeights = HeightBlend(controlWeights, height0, height1, height2, height3);
                
                // Sample albedo textures
                half4 albedo0 = SAMPLE_TEXTURE2D(_Splat0, sampler_Splat0, tiledUV);
                half4 albedo1 = SAMPLE_TEXTURE2D(_Splat1, sampler_Splat1, tiledUV);
                half4 albedo2 = SAMPLE_TEXTURE2D(_Splat2, sampler_Splat2, tiledUV);
                half4 albedo3 = SAMPLE_TEXTURE2D(_Splat3, sampler_Splat3, tiledUV);
                
                // Blend albedo
                half4 albedo = albedo0 * blendWeights.x + 
                              albedo1 * blendWeights.y + 
                              albedo2 * blendWeights.z + 
                              albedo3 * blendWeights.w;
                
                // Sample normal maps
                half3 normal0 = UnpackNormal(SAMPLE_TEXTURE2D(_Normal0, sampler_Normal0, tiledUV));
                half3 normal1 = UnpackNormal(SAMPLE_TEXTURE2D(_Normal1, sampler_Normal1, tiledUV));
                half3 normal2 = UnpackNormal(SAMPLE_TEXTURE2D(_Normal2, sampler_Normal2, tiledUV));
                half3 normal3 = UnpackNormal(SAMPLE_TEXTURE2D(_Normal3, sampler_Normal3, tiledUV));
                
                // Blend normals
                half3 normalTS = normal0 * blendWeights.x + 
                                normal1 * blendWeights.y + 
                                normal2 * blendWeights.z + 
                                normal3 * blendWeights.w;
                
                // Transform normal to world space
                float3 bitangentWS = cross(input.normalWS, input.tangentWS.xyz) * input.tangentWS.w;
                float3x3 TBN = float3x3(input.tangentWS.xyz, bitangentWS, input.normalWS);
                float3 normalWS = normalize(mul(normalTS, TBN));
                
                // Blend metallic and smoothness
                half metallic = _Metallic0 * blendWeights.x + 
                               _Metallic1 * blendWeights.y + 
                               _Metallic2 * blendWeights.z + 
                               _Metallic3 * blendWeights.w;
                
                half smoothness = _Smoothness0 * blendWeights.x + 
                                 _Smoothness1 * blendWeights.y + 
                                 _Smoothness2 * blendWeights.z + 
                                 _Smoothness3 * blendWeights.w;
                
                // Setup surface data
                InputData inputData = (InputData)0;
                inputData.positionWS = input.positionWS;
                inputData.normalWS = normalWS;
                inputData.viewDirectionWS = normalize(input.viewDirWS);
                inputData.shadowCoord = TransformWorldToShadowCoord(input.positionWS);
                inputData.fogCoord = input.fogFactor;
                
                // Setup surface data for PBR
                SurfaceData surfaceData = (SurfaceData)0;
                surfaceData.albedo = albedo.rgb;
                surfaceData.alpha = 1.0;
                surfaceData.metallic = metallic;
                surfaceData.smoothness = smoothness;
                surfaceData.normalTS = normalTS;
                surfaceData.emission = 0;
                surfaceData.occlusion = 1.0;
                
                // Calculate lighting
                half4 color = UniversalFragmentPBR(inputData, surfaceData);
                
                // Apply fog
                color.rgb = MixFog(color.rgb, input.fogFactor);
                
                return color;
            }
            ENDHLSL
        }
        
        // Shadow caster pass
        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }
            
            ZWrite On
            ZTest LEqual
            ColorMask 0
            
            HLSLPROGRAM
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            
            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };
            
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
            };
            
            float3 _LightDirection;
            
            Varyings ShadowPassVertex(Attributes input)
            {
                Varyings output;
                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                float3 normalWS = TransformObjectToWorldNormal(input.normalOS);
                
                output.positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, _LightDirection));
                
                #if UNITY_REVERSED_Z
                    output.positionCS.z = min(output.positionCS.z, output.positionCS.w * UNITY_NEAR_CLIP_VALUE);
                #else
                    output.positionCS.z = max(output.positionCS.z, output.positionCS.w * UNITY_NEAR_CLIP_VALUE);
                #endif
                
                return output;
            }
            
            half4 ShadowPassFragment(Varyings input) : SV_Target
            {
                return 0;
            }
            ENDHLSL
        }
        
        // Depth only pass
        Pass
        {
            Name "DepthOnly"
            Tags { "LightMode" = "DepthOnly" }
            
            ZWrite On
            ColorMask 0
            
            HLSLPROGRAM
            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            struct Attributes
            {
                float4 positionOS : POSITION;
            };
            
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
            };
            
            Varyings DepthOnlyVertex(Attributes input)
            {
                Varyings output;
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                return output;
            }
            
            half4 DepthOnlyFragment(Varyings input) : SV_Target
            {
                return 0;
            }
            ENDHLSL
        }
    }
    
    Fallback "Hidden/Universal Render Pipeline/FallbackError"
}
