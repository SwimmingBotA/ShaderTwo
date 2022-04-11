using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Clock : MonoBehaviour
{
    [SerializeField]int sID;
    [SerializeField] int mID;
    [SerializeField] int hID;
    [SerializeField] Material material;
    [SerializeField] bool pass;

    private void Start()
    {
        if (transform.GetChild(0).TryGetComponent<Renderer>(out Renderer renderer))
        {
            sID = Shader.PropertyToID("_SRotateID");
            mID = Shader.PropertyToID("_MRotateID");
            hID = Shader.PropertyToID("_HRotateID");

            if (renderer.material.HasProperty(sID) &&
               renderer.material.HasProperty(mID) &&
               renderer.material.HasProperty(hID))
            {
                material = renderer.material;
                pass = true;
            }
        }
        else
        {
            this.enabled = false;
        }
    }

    private void Update()
    {
        if(!pass) this.enabled = false;

        int second = System.DateTime.Now.Second;
        float sAngle = (second / 60.0f) * 2 * Mathf.PI;
        material.SetFloat(sID, sAngle);

        int minute = System.DateTime.Now.Minute;
        float mAngle = (minute / 60.0f) * 2 * Mathf.PI;
        material.SetFloat(mID, mAngle);

        int hinute = System.DateTime.Now.Hour;
        float hAngle = (hinute % 12.0f) * 2 * Mathf.PI/12.0f;
        material.SetFloat(hID, hAngle);
    }
}
