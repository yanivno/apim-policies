Implementing a user managed identity for each backend
1. create a user managed identity (in Azure - Managed Identities) and note the Client Ids.
2. Allow API Management to authenticate using the Managed Identities through APIM > Managed Identities > User Assigned Identities
3. Give OpenAI User role on the Open  AI Deploymentץ
4. edit the API Management policy to change authentication-managed-identity and modify it to :
        <!-- uami modifcation -->
        <authentication-managed-identity resource="https://cognitiveservices.azure.com" client-id="d7795132-6738-4434-b530-17a8f4b74ec1" output-token-variable-name="aoai-1-qkojak7tombza-token" ignore-error="false" />
        <authentication-managed-identity resource="https://cognitiveservices.azure.com" client-id="3f25ec8d-057f-41d7-bc62-90082999fc84" output-token-variable-name="aoai-2-qkojak7tombza-token" ignore-error="false" />
        <authentication-managed-identity resource="https://cognitiveservices.azure.com" client-id="233341be-edd8-4c5e-9103-fe62013bb1c5" output-token-variable-name="aoai-3-qkojak7tombza-token" ignore-error="false" />
        <authentication-managed-identity resource="https://cognitiveservices.azure.com" client-id="57880d92-757d-449e-b9e4-cfc4032c48c8" output-token-variable-name="ynorman-gpt-swe-token" ignore-error="false" />
        <!-- uami modification end -->
* add a line for each open ai route and corresponding managed identity.
* output-token-variable-name should have <NAME>-token (as you defined in routes array)
* client-id should have the correspoinding managed identity client-id matching to be used with open ai endpoint

5. remove the set-header for Authorization (below in policy) should be similar to :
        <set-header name="Authorization" exists-action="override">
            <value>@("Bearer " + (string)context.Variables["msi-access-token"])</value>
        </set-header>
6. add it to the backend routing fragment - API M > Policy Fragments > backend-routing > policy editor and add the following before line 72 (should be <forward-request buffer-request-body="true" /> ) and add the following : 
<set-header name="Authorization" exists-action="override">
    <value>@("Bearer " + (string)context.Variables[(string)context.Variables["routeName"] + "-token"])</value>
</set-header>

* we are getting the token from a variable called <NAME>-token and setting the authorization header

    