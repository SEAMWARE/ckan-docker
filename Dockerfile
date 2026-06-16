ARG CKAN_VERSION=2.11.5
ARG CKAN_PLATFORM=linux/amd64

FROM --platform=${CKAN_PLATFORM} ckan/ckan-base:${CKAN_VERSION}

ARG CKANEXT_ENVVARS_REF=master
ARG CKANEXT_HARVEST_REF=master
ARG CKANEXT_SCHEMING_REF=master
ARG CKANEXT_DCAT_REF=v2.4.3
ARG CKANEXT_OIDC4VC_REF=main
ARG CKANEXT_TMFORUM_REF=main
ARG CKANEXT_DSIF_REF=main
ARG CKANEXT_NGSILD_REF=main

ENV CKAN__PLUGINS="image_view text_view datatables_view datastore scheming_datasets scheming_groups scheming_organizations harvest dcat oidc4vc tmforum dsif ngsild envvars" \
    CKAN___SCHEMING__DATASET_SCHEMAS="ckanext.dcat.schemas:dcat_ap_recommended.yaml" \
    CKAN___SCHEMING__PRESETS="ckanext.scheming:presets.json ckanext.dcat.schemas:presets.yaml" \
    CKANEXT_DSIF_CATALOG_ID="ic-001" \
    CKANEXT_DSIF_SECTOR="smart-cities" \
    CKANEXT_DSIF_TITLE="Independent Catalog of Smart City Data" \
    CKANEXT_DSIF_DESCRIPTION="This catalog contains datasets related to smart cities." \
    CKANEXT_OIDC4VC_CLIENT_ID="data-service" \
    CKANEXT_OIDC4VC_REDIRECT_URI="/auth/oidc4vc/callback" \
    CKANEXT_OIDC4VC_SCOPES="operator" \
    CKANEXT_OIDC4VC_ISSUER="https://verifier.seamware.io" \
    CKANEXT_OIDC4VC_EMAIL_CLAIM="verifiableCredential.credentialSubject.email" \
    CKANEXT_OIDC4VC_FIRST_NAME_CLAIM="verifiableCredential.credentialSubject.firstName" \
    CKANEXT_OIDC4VC_LAST_NAME_CLAIM="verifiableCredential.credentialSubject.lastName" \
    CKANEXT_OIDC4VC_ORG_ID_CLAIM="verifiableCredential.issuer" \
    CKANEXT_OIDC4VC_ROLES_CLAIM="verifiableCredential.credentialSubject.roles" \
    CKANEXT_OIDC4VC_EDITOR_ROLE="ckan:editor" \
    CKANEXT_OIDC4VC_ORG_ADMIN_ROLE="ckan:admin" \
    CKANEXT_TMFORUM_OWNER_ROLE="Seller" \
    PIP_NO_INPUT="1"

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends git && \
    rm -rf /var/lib/apt/lists/*

RUN rm -rf "${APP_DIR}/src/ckanext-envvars" \
           "${APP_DIR}/src/ckanext-harvest" \
           "${APP_DIR}/src/ckanext-scheming" \
           "${APP_DIR}/src/ckanext-dcat" \
           "${APP_DIR}/src/ckanext-oidc4vc" \
           "${APP_DIR}/src/ckanext-tmforum" \
           "${APP_DIR}/src/ckanext-dsif" \
           "${APP_DIR}/src/ckanext-ngsild" && \
    pip install -e "git+https://github.com/ckan/ckanext-envvars.git@${CKANEXT_ENVVARS_REF}#egg=ckanext-envvars" && \
    pip install -e "git+https://github.com/ckan/ckanext-harvest.git@${CKANEXT_HARVEST_REF}#egg=ckanext-harvest" && \
    pip install -r "${APP_DIR}/src/ckanext-harvest/pip-requirements.txt" && \
    pip install -e "git+https://github.com/ckan/ckanext-scheming.git@${CKANEXT_SCHEMING_REF}#egg=ckanext-scheming" && \
    pip install -e "git+https://github.com/ckan/ckanext-dcat.git@${CKANEXT_DCAT_REF}#egg=ckanext-dcat" && \
    pip install -r "${APP_DIR}/src/ckanext-dcat/requirements.txt" && \
    pip install -e "git+https://github.com/SEAMWARE/ckanext-oidc4vc.git@${CKANEXT_OIDC4VC_REF}#egg=ckanext-oidc4vc" && \
    pip install -r "${APP_DIR}/src/ckanext-oidc4vc/requirements.txt" && \
    pip install -e "git+https://github.com/SEAMWARE/ckanext-tmforum.git@${CKANEXT_TMFORUM_REF}#egg=ckanext-tmforum" && \
    pip install -r "${APP_DIR}/src/ckanext-tmforum/requirements.txt" && \
    pip install -e "git+https://github.com/SEAMWARE/ckanext-dsif.git@${CKANEXT_DSIF_REF}#egg=ckanext-dsif" && \
    pip install -r "${APP_DIR}/src/ckanext-dsif/requirements.txt" && \
    pip install -e "git+https://github.com/SEAMWARE/ckanext-ngsild.git@${CKANEXT_NGSILD_REF}#egg=ckanext-ngsild" && \
    pip install -r "${APP_DIR}/src/ckanext-ngsild/requirements.txt"

USER ckan
