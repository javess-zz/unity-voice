using UnityEngine;
using UnityEngine.Networking;
using VoiceChat;
using VoiceChat.Networking;
using VoiceChat.Demo;

public class PlayerController : NetworkBehaviour
{
    public GameObject bulletPrefab;
    public GameObject voiceChatPrefab;
    public Transform bulletSpawn;
    public int bulletSpeed = 6;

    private GameObject voiceChat = null;

    void Start()
    {
    }

    void Update()
    {
        if (!isLocalPlayer)
        {
            return;
        }

        var x = Input.GetAxis("Horizontal") * Time.deltaTime * 30.0f;
        var z = Input.GetAxis("Vertical") * Time.deltaTime * 3.0f;

        transform.Rotate(0, x, 0);
        transform.Translate(0, 0, z);

        if (Input.GetKeyDown(KeyCode.Space))
        {
            CmdFire();
        }
    }

    [Command]
    void CmdFire()
    {
        // Create the Bullet from the Bullet Prefab
        var bullet = (GameObject)Instantiate(
            bulletPrefab.gameObject,
            bulletSpawn.position,
            bulletSpawn.rotation);
        var rigidBody = bullet.GetComponent<Rigidbody>();
        // Add velocity to the bullet
        rigidBody.velocity = rigidBody.transform.forward * bulletSpeed;

        // Spawn the bullet on the Clients
        NetworkServer.Spawn(bullet);

        // Destroy the bullet after 2 seconds
        Destroy(bullet, 2.0f);
    }

    public override void OnStartLocalPlayer()
    {
        GetComponent<MeshRenderer>().material.color = Color.blue;
        if (isClient) {
            var camera = Object.FindObjectOfType<OVRCameraRig>();
            camera.transform.parent = this.transform;
            camera.transform.localPosition = new Vector3(0, 1, 0);
            camera.transform.forward = transform.forward;
            GetComponent<MeshRenderer>().enabled = false;
            voiceChat = Instantiate<GameObject>(voiceChatPrefab.gameObject);
            voiceChat.transform.SetParent(transform);
			gameObject.AddComponent<VoiceChatUi>();
        }
    }
}