using UnityEngine;

[ExecuteInEditMode]
public class TestSectionPlane : MonoBehaviour
{
    public GameObject plane;
    void Update()
    {
        Vector3 normal = -plane.transform.forward;
        Vector3 pos = plane.transform.position;

        GetComponent<MeshRenderer>().sharedMaterial.SetFloat("_X", normal.x);
        GetComponent<MeshRenderer>().sharedMaterial.SetFloat("_Y", normal.y);
        GetComponent<MeshRenderer>().sharedMaterial.SetFloat("_Z", normal.z);

        GetComponent<MeshRenderer>().material.SetFloat("_XC", pos.x);
        GetComponent<MeshRenderer>().material.SetFloat("_YC", pos.y);
        GetComponent<MeshRenderer>().material.SetFloat("_ZC", pos.z);

    }
}
